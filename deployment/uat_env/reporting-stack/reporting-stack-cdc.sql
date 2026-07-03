-- =============================================================================
-- Reporting Stack: CDC bootstrap objects for the UAT source database (RDS)
-- =============================================================================
-- This script is idempotent — safe to run multiple times. It is applied to the
-- uat RDS instance by deploy_to_uat_env.sh on EVERY deploy, because a
-- KEEP_OR_RESTORE=restore build reloads demo data (Flyway drops and recreates
-- the source tables) and PostgreSQL silently removes recreated tables from
-- publications.
--
-- Mirrors openlmis-ref-distro/reporting-stack/init-db.sql, minus the
-- `ALTER ROLE ... WITH REPLICATION` step: that fails on RDS, where the master
-- user is not a true superuser. Replication rights come from a one-time
-- `GRANT rds_replication TO <db user>` instead (see reporting-stack-rollout.md,
-- Step 1).
--
-- KEEP IN SYNC: the table list below must match
--   * SOURCE_PG_TABLE_ALLOWLIST in openlmis-config/uat-reporting-stack.env
--   * openlmis-ref-distro/reporting-stack/init-db.sql
-- The connector-registration preflight fails if they drift apart.
-- =============================================================================

-- 1. Heartbeat table: Debezium writes to this periodically to advance the
--    replication slot, preventing WAL accumulation during idle periods.
CREATE TABLE IF NOT EXISTS public.reporting_heartbeat (
  id  INT PRIMARY KEY DEFAULT 1,
  ts  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
INSERT INTO public.reporting_heartbeat (id, ts) VALUES (1, NOW())
  ON CONFLICT (id) DO NOTHING;

-- 2. Signal table: Debezium reads rows inserted here to trigger ad-hoc actions
--    such as incremental snapshots (used by `make snapshot-tables` for selective
--    re-snapshot of newly added tables without resetting all offsets).
--    Schema follows the Debezium 3.x source signal channel contract.
CREATE TABLE IF NOT EXISTS public.debezium_signal (
  id   VARCHAR(42)   PRIMARY KEY,
  type VARCHAR(32)   NOT NULL,
  data VARCHAR(2048)
);

-- 3. Publication: list of tables whose changes Debezium will capture.
--    The signal table is included unconditionally — required by Debezium's
--    source signal channel.
--
--    Two-step approach for idempotency:
--    a) CREATE if it doesn't exist (first run)
--    b) SET TABLE always (handles tables dropped and recreated by Flyway
--       in demo/refresh-db mode — PostgreSQL silently removes recreated
--       tables from publications)
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_publication WHERE pubname = 'dbz_publication') THEN
    CREATE PUBLICATION dbz_publication FOR TABLE
      public.debezium_signal,
      referencedata.facilities,
      referencedata.programs,
      referencedata.geographic_zones,
      referencedata.orderables,
      referencedata.processing_periods,
      referencedata.processing_schedules,
      referencedata.facility_types,
      referencedata.supported_programs,
      referencedata.requisition_group_members,
      referencedata.requisition_group_program_schedules,
      requisition.requisitions,
      requisition.requisition_line_items,
      requisition.status_changes,
      requisition.stock_adjustments,
      requisition.stock_adjustment_reasons;
    RAISE NOTICE 'Created publication dbz_publication';
  ELSE
    RAISE NOTICE 'Publication dbz_publication already exists — ensuring tables are included';
  END IF;
END $$;

-- Always re-set the table list. This is a no-op if the tables are already
-- correct, and fixes the publication if tables were dropped/recreated.
ALTER PUBLICATION dbz_publication SET TABLE
  public.debezium_signal,
  referencedata.facilities,
  referencedata.programs,
  referencedata.geographic_zones,
  referencedata.orderables,
  referencedata.processing_periods,
  referencedata.processing_schedules,
  referencedata.facility_types,
  referencedata.supported_programs,
  referencedata.requisition_group_members,
  referencedata.requisition_group_program_schedules,
  requisition.requisitions,
  requisition.requisition_line_items,
  requisition.status_changes,
  requisition.stock_adjustments,
  requisition.stock_adjustment_reasons;

-- 4. WAL retention safety (max_slot_wal_keep_size) is an RDS parameter-group
--    setting on UAT — see reporting-stack-rollout.md Step 1. ALTER SYSTEM is not
--    available to the RDS master user.
