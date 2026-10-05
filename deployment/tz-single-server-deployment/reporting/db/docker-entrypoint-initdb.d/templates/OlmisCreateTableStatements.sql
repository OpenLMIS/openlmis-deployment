DROP VIEW IF EXISTS vw_requisition_timeliness;

DROP VIEW IF EXISTS vw_requisition_timeliness_base;

DROP VIEW IF EXISTS vw_tracer_products;

DROP VIEW IF EXISTS vw_facilities_information;
DROP TABLE IF EXISTS tracer_orderables;

CREATE TABLE public.tracer_orderables (orderable_code text NOT NULL,
                                                           facility_level_code text NOT NULL);


ALTER TABLE public.tracer_orderables OWNER TO postgres;

CREATE VIEW public.vw_facilities_information AS
SELECT f.id AS facility_id,
       f.code AS facility_code,
       f.name AS facility_name,
       f.enabled AS facility_enabled,
       f.description AS facility_description,
       f.comment AS facility_comment,
       ft.id AS facility_type_id,
       ft.code AS facility_type_code,
       ft.name AS facility_type_name,
       ft.primaryhealthcare AS is_facility_type_primary_health_care,
       6 AS facility_type_nominal_max_month,
       gz1.id AS zone1_id,
       gz1.code AS zone1_code,
       gz1.name AS zone1_name,
       gzic1.iso_code AS zone1_iso_code,
       gz2.id AS zone2_id,
       gz2.code AS zone2_code,
       gz2.name AS zone2_name,
       gzic2.iso_code AS zone2_iso_code,
       gl1.id AS level1_id,
       gl1.code AS level1_code,
       gl1.name AS level1_name,
       gl2.id AS level2_id,
       gl2.code AS level2_code,
       gl2.name AS level2_name
FROM kafka_facilities f
JOIN kafka_facility_types ft ON f.typeid = ft.id
JOIN kafka_geographic_zones gz1 ON gz1.id = f.geographiczoneid
LEFT JOIN geographic_zone_iso_codes gzic1 ON gz1.id::text = gzic1.geographic_zone_id::text
JOIN kafka_geographic_levels gl1 ON gz1.levelid = gl1.id
JOIN kafka_geographic_zones gz2 ON gz1.parentid = gz2.id
LEFT JOIN geographic_zone_iso_codes gzic2 ON gz2.id::text = gzic2.geographic_zone_id::text
JOIN kafka_geographic_levels gl2 ON gz2.levelid = gl2.id;


ALTER TABLE public.vw_facilities_information OWNER TO postgres;


DROP VIEW IF EXISTS vw_periods_information;


CREATE VIEW public.vw_periods_information AS
SELECT pp.id AS period_id,
       pp.name AS period_name,
       pp.description AS period_description,
       pp.startdate AS period_start_date,
       pp.enddate AS period_end_date,
       ps.id AS schedule_id,
       ps.code AS schedule_code,
       ps.name AS schedule_name,
       to_char(pp.startdate::timestamp WITH TIME ZONE, 'Mon'::text) AS period_month,
       date_part('year'::text, pp.startdate) AS period_year
FROM kafka_processing_periods pp
JOIN kafka_processing_schedules ps ON pp.processingscheduleid = ps.id;

ALTER TABLE public.vw_periods_information OWNER TO postgres;

DROP VIEW IF EXISTS vw_product_information;

CREATE VIEW public.vw_product_information AS
SELECT p.id AS product_id,
       p.code AS product_code,
       p.fullproductname AS product_full_name,
       p.description AS product_description,
       p.netcontent AS product_net_content,
       p.packroundingthreshold AS product_pack_rounding_threshold,
       p.dispensableid AS product_dispensable_id
FROM kafka_orderables p;


ALTER TABLE public.vw_product_information OWNER TO postgres;


DROP VIEW IF EXISTS vw_requisition_information;


CREATE VIEW public.vw_requisition_information AS
SELECT r.id AS requisition_id,
       r.createddate AS requisition_created_date,
       r.emergency AS requisition_is_emergency,
       r.status AS requisition_status,
       pr.id AS program_id,
       pr.code AS program_code,
       pr.name AS program_name,
       pi.period_id,
       pi.period_name,
       pi.period_description,
       pi.period_start_date,
       pi.period_end_date,
       pi.schedule_id,
       pi.schedule_code,
       pi.schedule_name,
       pi.period_month,
       pi.period_year,
       fi.facility_id,
       fi.facility_code,
       fi.facility_name,
       fi.facility_enabled,
       fi.facility_description,
       fi.facility_comment,
       fi.facility_type_id,
       fi.facility_type_code,
       fi.facility_type_name,
       fi.is_facility_type_primary_health_care,
       fi.facility_type_nominal_max_month,
       fi.zone1_id,
       fi.zone1_code,
       fi.zone1_name,
       fi.zone1_iso_code,
       fi.zone2_id,
       fi.zone2_code,
       fi.zone2_name,
       fi.zone2_iso_code,
       fi.level1_id,
       fi.level1_code,
       fi.level1_name,
       fi.level2_id,
       fi.level2_code,
       fi.level2_name,
       CASE
           WHEN r.status = 'INITIATED'::text THEN 1
           ELSE 0
       END AS is_initiated,
       CASE
           WHEN r.status = 'SUBMITTED'::text THEN 1
           ELSE 0
       END AS is_submitted,
       CASE
           WHEN r.status = 'SKIPPED'::text THEN 1
           ELSE 0
       END AS is_skipped,
       CASE
           WHEN r.status = 'AUTHORIZED'::text THEN 1
           ELSE 0
       END AS is_authorized,
       CASE
           WHEN r.status = 'IN_APPROVAL'::text THEN 1
           ELSE 0
       END AS is_in_approval,
       CASE
           WHEN r.status = 'APPROVED'::text THEN 1
           ELSE 0
       END AS is_approved,
       CASE
           WHEN r.status = 'RELEASED'::text THEN 1
           ELSE 0
       END AS is_released
FROM kafka_requisitions r
JOIN kafka_programs pr ON r.programid = pr.id
JOIN vw_facilities_information fi ON r.facilityid = fi.facility_id
JOIN vw_periods_information pi ON r.processingperiodid = pi.period_id;


ALTER TABLE public.vw_requisition_information OWNER TO postgres;


DROP VIEW IF EXISTS vw_requisition_line_items_information;


CREATE VIEW public.vw_requisition_line_items_information AS
SELECT ri.requisition_id,
       ri.requisition_created_date,
       ri.requisition_is_emergency,
       ri.requisition_status,
       ri.program_id,
       ri.program_code,
       ri.program_name,
       ri.period_id,
       ri.period_name,
       ri.period_description,
       ri.period_start_date,
       ri.period_end_date,
       ri.schedule_id,
       ri.schedule_code,
       ri.schedule_name,
       ri.period_month,
       ri.period_year,
       ri.facility_id,
       ri.facility_code,
       ri.facility_name,
       ri.facility_enabled,
       ri.facility_description,
       ri.facility_comment,
       ri.facility_type_id,
       ri.facility_type_code,
       ri.facility_type_name,
       ri.is_facility_type_primary_health_care,
       ri.facility_type_nominal_max_month,
       ri.zone1_id,
       ri.zone1_code,
       ri.zone1_name,
       ri.zone1_iso_code,
       ri.zone2_id,
       ri.zone2_code,
       ri.zone2_name,
       ri.zone2_iso_code,
       ri.level1_id,
       ri.level1_code,
       ri.level1_name,
       ri.level2_id,
       ri.level2_code,
       ri.level2_name,
       ri.is_initiated,
       ri.is_submitted,
       ri.is_skipped,
       ri.is_authorized,
       ri.is_in_approval,
       ri.is_approved,
       ri.is_released,
       p.product_id,
       p.product_code,
       p.product_full_name,
       p.product_description,
       p.product_net_content,
       p.product_pack_rounding_threshold,
       p.product_dispensable_id,
       li.totalstockoutdays AS line_item_stockout_days,
       li.skipped AS line_item_skipped,
       li.stockonhand AS line_item_stock_in_hand,
       CASE
           WHEN COALESCE(li.averageconsumption, 0) = 0 THEN 0::numeric
           ELSE trunc(round(li.stockonhand::numeric / li.averageconsumption::numeric, 2), 1)
       END AS mos,
       li.averageconsumption AS amc,
       COALESCE(CASE
                    WHEN (COALESCE(li.averageconsumption, 0) * ri.facility_type_nominal_max_month - li.stockonhand) < 0 THEN 0
                    ELSE COALESCE(li.averageconsumption, 0) * ri.facility_type_nominal_max_month - li.stockonhand
                END, 0) AS line_item_required_quantity,
       li.beginningbalance AS line_item_beginning_balance,
       li.totallossesandadjustments AS line_item_total_losses_and_adjustments,
       li.requestedquantity AS line_item_quantity_requested,
       li.approvedquantity AS line_item_quantity_approved,
       li.quantitytoissue AS line_item_quantity_dispensed,
       li.totalreceivedquantity AS line_item_quantity_received,
       pgp.priceperpack AS product_current_price,
       fap.minperiodsofstock AS product_min_months_of_stock,
       fap.maxperiodsofstock AS product_max_months_of_stock
FROM kafka_requisition_line_items li
JOIN vw_requisition_information ri ON li.requisitionid = ri.requisition_id
JOIN vw_product_information p ON p.product_id = li.orderableid
JOIN kafka_program_orderables pgp ON ri.program_id = pgp.programid
AND p.product_id = pgp.orderableid
JOIN kafka_facility_type_approved_products fap ON fap.facilitytypeid = ri.facility_type_id
AND fap.programid = ri.program_id
AND fap.orderableid = p.product_id;


ALTER TABLE public.vw_requisition_line_items_information OWNER TO postgres;


DROP VIEW IF EXISTS vw_facility_stock_availability;


DROP MATERIALIZED VIEW IF EXISTS mv_facility_stock_availability;


CREATE materialized VIEW public.mv_facility_stock_availability AS
SELECT li.requisition_id,
       li.requisition_created_date,
       li.requisition_is_emergency,
       li.requisition_status,
       li.program_id,
       li.program_code,
       li.program_name,
       li.period_id,
       li.period_name,
       li.period_description,
       li.period_start_date,
       li.period_end_date,
       li.schedule_id,
       li.schedule_code,
       li.schedule_name,
       li.period_month,
       li.period_year,
       li.facility_id,
       li.facility_code,
       li.facility_name,
       li.facility_enabled,
       li.facility_description,
       li.facility_comment,
       li.facility_type_id,
       li.facility_type_code,
       li.facility_type_name,
       li.is_facility_type_primary_health_care,
       li.facility_type_nominal_max_month,
       li.zone1_id,
       li.zone1_code,
       li.zone1_name,
       li.zone1_iso_code,
       li.zone2_id,
       li.zone2_code,
       li.zone2_name,
       li.zone2_iso_code,
       li.level1_id,
       li.level1_code,
       li.level1_name,
       li.level2_id,
       li.level2_code,
       li.level2_name,
       li.is_initiated,
       li.is_submitted,
       li.is_skipped,
       li.is_authorized,
       li.is_in_approval,
       li.is_approved,
       li.is_released,
       li.product_id,
       li.product_code,
       li.product_full_name,
       li.product_description,
       li.product_net_content,
       li.product_pack_rounding_threshold,
       li.product_dispensable_id,
       li.line_item_stockout_days,
       li.line_item_skipped,
       li.line_item_stock_in_hand,
       li.mos,
       li.amc,
       li.line_item_required_quantity,
       li.line_item_beginning_balance,
       li.line_item_total_losses_and_adjustments,
       li.line_item_quantity_requested,
       li.line_item_quantity_approved,
       li.line_item_quantity_dispensed,
       li.line_item_quantity_received,
       li.product_current_price,
       li.product_min_months_of_stock,
       li.product_max_months_of_stock,
       CASE
           WHEN COALESCE(li.line_item_stock_in_hand, 0) = 0 THEN 'SO'::text
           WHEN COALESCE(li.amc, 0) = 0 THEN 'UK'::text
           WHEN trunc(round(li.line_item_stock_in_hand::numeric / li.amc::numeric, 2), 1) > li.product_max_months_of_stock::numeric THEN 'OS'::text
           WHEN trunc(round(li.line_item_stock_in_hand::numeric / li.amc::numeric, 2), 1)::double precision < li.product_min_months_of_stock THEN 'US'::text
           WHEN trunc(round(li.line_item_stock_in_hand::numeric / li.amc::numeric, 2), 1) <= li.product_max_months_of_stock::numeric
                AND trunc(round(li.line_item_stock_in_hand::numeric / li.amc::numeric, 2), 1)::double precision >= li.product_min_months_of_stock THEN 'SP'::text
           ELSE 'UK'::text
       END AS stock_availability_status
FROM vw_requisition_line_items_information li
WHERE (li.requisition_status = ANY (ARRAY ['APPROVED'::character varying::text, 'RELEASED'::character varying::text, 'IN_APPROVAL'::character varying::text, 'RELEASED_WITHOUT_ORDER'::character varying::text]))
  AND li.line_item_skipped = FALSE
  AND (li.line_item_beginning_balance > 0
       OR li.line_item_quantity_received > 0
       OR abs(li.line_item_total_losses_and_adjustments) > 0
       OR li.line_item_quantity_dispensed > 0
       OR li.line_item_quantity_approved > 0)
  AND li.requisition_created_date > '2023-01-01' WITH NO DATA;



ALTER materialized VIEW public.mv_facility_stock_availability OWNER TO postgres;


CREATE INDEX idx_requisition_created_date ON public.mv_facility_stock_availability (requisition_created_date);


CREATE INDEX idx_facility_type_name ON public.mv_facility_stock_availability (facility_type_name);


CREATE INDEX idx_program_name ON public.mv_facility_stock_availability (program_name);


CREATE INDEX idx_zone1_name ON public.mv_facility_stock_availability (zone1_name);


CREATE INDEX idx_zone2_name ON public.mv_facility_stock_availability (zone2_name);


CREATE INDEX idx_period_start_date ON public.mv_facility_stock_availability (period_start_date);


CREATE INDEX idx_facility_name ON public.mv_facility_stock_availability (facility_name);


CREATE INDEX idx_product_code ON public.mv_facility_stock_availability (product_code);


CREATE INDEX idx_product_full_name ON public.mv_facility_stock_availability (product_full_name);


CREATE INDEX idx_period_year ON public.mv_facility_stock_availability (period_year);


CREATE VIEW public.vw_facility_stock_availability AS
SELECT mv_facility_stock_availability.requisition_id,
       mv_facility_stock_availability.requisition_created_date,
       mv_facility_stock_availability.requisition_is_emergency,
       mv_facility_stock_availability.requisition_status,
       mv_facility_stock_availability.program_id,
       mv_facility_stock_availability.program_code,
       mv_facility_stock_availability.program_name,
       mv_facility_stock_availability.period_id,
       mv_facility_stock_availability.period_name,
       mv_facility_stock_availability.period_description,
       mv_facility_stock_availability.period_start_date,
       mv_facility_stock_availability.period_end_date,
       mv_facility_stock_availability.schedule_id,
       mv_facility_stock_availability.schedule_code,
       mv_facility_stock_availability.schedule_name,
       mv_facility_stock_availability.period_month,
       mv_facility_stock_availability.period_year,
       mv_facility_stock_availability.facility_id,
       mv_facility_stock_availability.facility_code,
       mv_facility_stock_availability.facility_name,
       mv_facility_stock_availability.facility_enabled,
       mv_facility_stock_availability.facility_description,
       mv_facility_stock_availability.facility_comment,
       mv_facility_stock_availability.facility_type_id,
       mv_facility_stock_availability.facility_type_code,
       mv_facility_stock_availability.facility_type_name,
       mv_facility_stock_availability.is_facility_type_primary_health_care,
       mv_facility_stock_availability.facility_type_nominal_max_month,
       mv_facility_stock_availability.zone1_id,
       mv_facility_stock_availability.zone1_code,
       mv_facility_stock_availability.zone1_name,
       mv_facility_stock_availability.zone1_iso_code,
       mv_facility_stock_availability.zone2_id,
       mv_facility_stock_availability.zone2_code,
       mv_facility_stock_availability.zone2_name,
       mv_facility_stock_availability.zone2_iso_code,
       mv_facility_stock_availability.level1_id,
       mv_facility_stock_availability.level1_code,
       mv_facility_stock_availability.level1_name,
       mv_facility_stock_availability.level2_id,
       mv_facility_stock_availability.level2_code,
       mv_facility_stock_availability.level2_name,
       mv_facility_stock_availability.is_initiated,
       mv_facility_stock_availability.is_submitted,
       mv_facility_stock_availability.is_skipped,
       mv_facility_stock_availability.is_authorized,
       mv_facility_stock_availability.is_in_approval,
       mv_facility_stock_availability.is_approved,
       mv_facility_stock_availability.is_released,
       mv_facility_stock_availability.product_id,
       mv_facility_stock_availability.product_code,
       mv_facility_stock_availability.product_full_name,
       mv_facility_stock_availability.product_description,
       mv_facility_stock_availability.product_net_content,
       mv_facility_stock_availability.product_pack_rounding_threshold,
       mv_facility_stock_availability.product_dispensable_id,
       mv_facility_stock_availability.line_item_stockout_days,
       mv_facility_stock_availability.line_item_skipped,
       mv_facility_stock_availability.line_item_stock_in_hand,
       mv_facility_stock_availability.mos,
       mv_facility_stock_availability.amc,
       mv_facility_stock_availability.line_item_required_quantity,
       mv_facility_stock_availability.line_item_beginning_balance,
       mv_facility_stock_availability.line_item_total_losses_and_adjustments,
       mv_facility_stock_availability.line_item_quantity_requested,
       mv_facility_stock_availability.line_item_quantity_approved,
       mv_facility_stock_availability.line_item_quantity_dispensed,
       mv_facility_stock_availability.line_item_quantity_received,
       mv_facility_stock_availability.product_current_price,
       mv_facility_stock_availability.product_min_months_of_stock,
       mv_facility_stock_availability.product_max_months_of_stock,
       mv_facility_stock_availability.stock_availability_status,
       CASE
           WHEN mv_facility_stock_availability.stock_availability_status = 'SP'::text THEN 1
           ELSE 0
       END AS sp,
       CASE
           WHEN mv_facility_stock_availability.stock_availability_status = 'SO'::text THEN 1
           ELSE 0
       END AS so,
       CASE
           WHEN mv_facility_stock_availability.stock_availability_status = 'OS'::text THEN 1
           ELSE 0
       END AS os,
       CASE
           WHEN mv_facility_stock_availability.stock_availability_status = 'US'::text THEN 1
           ELSE 0
       END AS us,
       CASE
           WHEN mv_facility_stock_availability.stock_availability_status = 'RND'::text THEN 1
           ELSE 0
       END AS rnd,
       CASE
           WHEN mv_facility_stock_availability.stock_availability_status = 'UK'::text THEN 1
           ELSE 0
       END AS uk,
       CASE
           WHEN mv_facility_stock_availability.stock_availability_status = 'SO'::text THEN 'Stocked Out'::text
           WHEN mv_facility_stock_availability.stock_availability_status = 'SP'::text THEN 'Adequately Stocked'::text
           WHEN mv_facility_stock_availability.stock_availability_status = 'US'::text THEN 'Under Stocked'::text
           WHEN mv_facility_stock_availability.stock_availability_status = 'OS'::text THEN 'Over Stocked'::text
           WHEN mv_facility_stock_availability.stock_availability_status = 'RND'::text THEN 'Not Enough Data'::text
           ELSE 'Unknown'::text
       END AS stock_availability_description
FROM mv_facility_stock_availability;


ALTER TABLE public.vw_facility_stock_availability OWNER TO postgres;


CREATE materialized VIEW public.mv_districts AS
SELECT d.id AS district_id,
       d.name AS district_name,
       r.id AS region_id,
       r.name AS region_name,
       z.id AS zone_id,
       z.name AS zone_name,
       z.parentid AS parent
FROM kafka_geographic_zones d
JOIN kafka_geographic_zones r ON d.parentid = r.id
JOIN kafka_geographic_zones z ON z.id = r.parentid WITH NO DATA;


ALTER materialized VIEW public.mv_districts OWNER TO postgres;

CREATE materialized VIEW public.mv_stock_imbalance_by_facility_report AS
SELECT gz.region_name AS supplyingfacility,
       gz.region_name,
       gz.district_name,
       gz.zone_name,
       f.code AS facilitycode,
       p.code AS productcode,
       f.name AS facility,
       p.fullproductname AS product,
       ft.name AS facilitytypename,
       gz.district_name AS LOCATION,
       pp.name AS processing_period_name,
       li.totalstockoutdays,
       to_char(pp.startdate::timestamp WITH TIME ZONE, 'Mon'::text) AS asmonth,
       date_part('year'::text, pp.startdate) AS YEAR,
       r.processingperiodid AS periodid,
       r.programid,
       f.id AS facility_id,
       gz.zone_id,
       gz.parent,
       gz.region_id,
       gz.district_id,
       r.emergency,
       li.skipped,
       pg.code AS program,
       pg.name AS programname,
       f.typeid AS facility_type_id,
       ft.primaryhealthcare,
       pgp.orderabledisplaycategoryid AS productcategoryid,
       p.id AS productid,
       CASE
           WHEN COALESCE(li.stockonhand, 0) = 0 THEN 'Stocked Out'::text
           WHEN COALESCE(li.averageconsumption, 0) = 0 THEN 'No Demand (AMC=0)'::text
           WHEN trunc(round(li.stockonhand::numeric / li.averageconsumption::numeric, 2), 1) > fap.maxperiodsofstock::numeric THEN 'Over Stocked'::text
           WHEN trunc(round(li.stockonhand::numeric / li.averageconsumption::numeric, 2), 1)::double precision < fap.minperiodsofstock THEN 'Under Stocked'::text
           WHEN trunc(round(li.stockonhand::numeric / li.averageconsumption::numeric, 2), 1) <= fap.maxperiodsofstock::numeric
                AND trunc(round(li.stockonhand::numeric / li.averageconsumption::numeric, 2), 1)::double precision >= fap.minperiodsofstock THEN 'Adequately Stocked'::text
           ELSE 'No Demand (AMC=0)'::text
       END AS status,
       li.requestedquantity,
       li.stockonhand,
       CASE
           WHEN COALESCE(li.averageconsumption, 0) = 0 THEN 0::numeric
           ELSE trunc(round(li.stockonhand::numeric / li.averageconsumption::numeric, 2), 1)
       END AS mos,
       li.averageconsumption,
       COALESCE(CASE
                    WHEN (COALESCE(li.averageconsumption, 0) * 4 - li.stockonhand) < 0 THEN 0
                    ELSE COALESCE(li.averageconsumption, 0) * 4 - li.stockonhand
                END, 0) AS required,
       li.approvedquantity AS ordered,
       li.beginningbalance,
       li.totalreceivedquantity,
       li.totallossesandadjustments,
       li.totalconsumedquantity,
       li.approvedquantity,
       ps.name AS schedule,
       ps.id AS scheduleid,
       pgp.priceperpack AS currentprice,
       geo.iso_code AS geo_iso
FROM kafka_processing_periods pp
JOIN kafka_processing_schedules ps ON pp.processingscheduleid = ps.id
JOIN kafka_requisitions r ON pp.id = r.processingperiodid
JOIN kafka_requisition_line_items li ON li.requisitionid = r.id
JOIN kafka_facilities f ON f.id = r.facilityid
JOIN kafka_facility_types ft ON ft.id = f.typeid
JOIN kafka_orderables p ON p.id = li.orderableid
JOIN mv_districts gz ON gz.district_id = f.geographiczoneid
JOIN kafka_programs pg ON pg.id = r.programid
JOIN kafka_program_orderables pgp ON r.programid = pgp.programid
AND p.id = pgp.orderableid
JOIN kafka_facility_type_approved_products fap ON ft.id = fap.facilitytypeid
AND fap.programid = pgp.programid
AND fap.orderableid = pgp.orderableid
JOIN geographic_zone_iso_codes geo ON gz.region_id::TEXT = geo.geographic_zone_id::TEXT
WHERE pp.startdate >= '2019-09-01'::date
  AND (r.status = ANY (ARRAY ['APPROVED'::character varying, 'RELEASED'::character varying, 'IN_APPROVAL'::character varying, 'RELEASED_NO_ORDER'::character varying]::text[]))
  AND li.skipped = FALSE
  AND (li.beginningbalance > 0
       OR li.totalreceivedquantity > 0
       OR abs(li.totallossesandadjustments) > 0
       OR li.totalconsumedquantity > 0
       OR li.approvedquantity > 0)
  AND r.emergency = FALSE WITH NO DATA;

ALTER materialized VIEW public.mv_stock_imbalance_by_facility_report OWNER TO postgres;


CREATE materialized VIEW public.view_stock_imbalance_by_facility_report_aggregate AS WITH subquery AS
  (SELECT mv_stock_imbalance_by_facility_report.programid,
          mv_stock_imbalance_by_facility_report.periodid,
          mv_stock_imbalance_by_facility_report.program,
          mv_stock_imbalance_by_facility_report.programname,
          mv_stock_imbalance_by_facility_report.facilitycode,
          mv_stock_imbalance_by_facility_report.facilitytypename,
          mv_stock_imbalance_by_facility_report.processing_period_name,
          mv_stock_imbalance_by_facility_report.asmonth,
          mv_stock_imbalance_by_facility_report.year,
          mv_stock_imbalance_by_facility_report.emergency,
          mv_stock_imbalance_by_facility_report.schedule,
          mv_stock_imbalance_by_facility_report.geo_iso,
          CASE
              WHEN mv_stock_imbalance_by_facility_report.status = 'Stocked Out'::text THEN 'Stocked Out'::text
              WHEN mv_stock_imbalance_by_facility_report.status = 'Adequately Stocked'::text THEN 'Adequately Stocked'::text
              WHEN mv_stock_imbalance_by_facility_report.status = 'Under Stocked'::text THEN 'Under Stocked'::text
              WHEN mv_stock_imbalance_by_facility_report.status = 'Over Stocked'::text THEN 'Over Stocked'::text
              ELSE 'No Demand (AMC=0)'::text
          END AS status,
          sum(mv_stock_imbalance_by_facility_report.requestedquantity) AS requestedquantity,
          sum(mv_stock_imbalance_by_facility_report.mos) AS mos,
          sum(mv_stock_imbalance_by_facility_report.averageconsumption) AS averageconsumption,
          sum(mv_stock_imbalance_by_facility_report.required) AS required,
          sum(mv_stock_imbalance_by_facility_report.ordered) AS ordered,
          sum(mv_stock_imbalance_by_facility_report.beginningbalance) AS beginningbalance,
          sum(mv_stock_imbalance_by_facility_report.totalreceivedquantity) AS totalreceivedquantity,
          sum(mv_stock_imbalance_by_facility_report.totallossesandadjustments) AS totallossesandadjustments,
          sum(mv_stock_imbalance_by_facility_report.totalconsumedquantity) AS totalconsumedquantity,
          sum(mv_stock_imbalance_by_facility_report.approvedquantity) AS approvedquantity,
          sum(mv_stock_imbalance_by_facility_report.totalstockoutdays) AS totalstockoutdays,
          sum(mv_stock_imbalance_by_facility_report.stockonhand) AS stockonhand,
          mv_stock_imbalance_by_facility_report.facility,
          mv_stock_imbalance_by_facility_report.district_name,
          mv_stock_imbalance_by_facility_report.region_name,
          mv_stock_imbalance_by_facility_report.status AS status2,
          count(*) AS numirator,
          sum(CASE
                  WHEN mv_stock_imbalance_by_facility_report.status = 'Stocked Out'::text THEN 1
                  WHEN mv_stock_imbalance_by_facility_report.status = 'No Demand (AMC=0)'::text THEN 1
                  WHEN mv_stock_imbalance_by_facility_report.status = 'Over Stocked'::text THEN 1
                  WHEN mv_stock_imbalance_by_facility_report.status = 'Under Stocked'::text THEN 1
                  WHEN mv_stock_imbalance_by_facility_report.status = 'Adequately Stocked'::text THEN 1
                  ELSE 0
              END) AS total
   FROM mv_stock_imbalance_by_facility_report
   WHERE mv_stock_imbalance_by_facility_report.product <> 'NULL'::text
   GROUP BY mv_stock_imbalance_by_facility_report.facility,
            mv_stock_imbalance_by_facility_report.status,
            mv_stock_imbalance_by_facility_report.district_name,
            mv_stock_imbalance_by_facility_report.region_name,
            mv_stock_imbalance_by_facility_report.facilitycode,
            mv_stock_imbalance_by_facility_report.facilitytypename,
            mv_stock_imbalance_by_facility_report.processing_period_name,
            mv_stock_imbalance_by_facility_report.asmonth,
            mv_stock_imbalance_by_facility_report.year,
            mv_stock_imbalance_by_facility_report.emergency,
            mv_stock_imbalance_by_facility_report.schedule,
            mv_stock_imbalance_by_facility_report.geo_iso,
            mv_stock_imbalance_by_facility_report.program,
            mv_stock_imbalance_by_facility_report.programname,
            mv_stock_imbalance_by_facility_report.periodid,
            mv_stock_imbalance_by_facility_report.programid)
SELECT s.programid,
       s.periodid,
       s.program,
       s.programname,
       s.facilitycode,
       s.facilitytypename,
       s.processing_period_name,
       s.asmonth,
       s.year,
       s.emergency,
       s.schedule,
       s.geo_iso,
       s.status2,
       sum(s.requestedquantity) AS requestedquantity,
       sum(s.mos) AS mos,
       sum(s.averageconsumption) AS averageconsumption,
       sum(s.required) AS required,
       sum(s.ordered) AS ordered,
       sum(s.beginningbalance) AS beginningbalance,
       sum(s.totalreceivedquantity) AS totalreceivedquantity,
       sum(s.totallossesandadjustments) AS totallossesandadjustments,
       sum(s.totalconsumedquantity) AS totalconsumedquantity,
       sum(s.approvedquantity) AS approvedquantity,
       sum(s.totalstockoutdays) AS totalstockoutdays,
       sum(s.stockonhand) AS stockonhand,
       s.status,
       sum(s.numirator) AS total_numirator,
       s.district_name,
       s.region_name,
       sum(r.running_total) AS running_total,
       round((sum(s.total) / NULLIF(sum(r.running_total), 0::numeric))::double precision * 100::double precision) AS perc_adm
FROM subquery s
JOIN
  (SELECT subquery.periodid,
          subquery.facilitycode,
          subquery.programid,
          subquery.facility,
          subquery.district_name,
          subquery.region_name,
          sum(subquery.total) AS running_total
   FROM subquery
   GROUP BY subquery.facility,
            subquery.district_name,
            subquery.region_name,
            subquery.facilitycode,
            subquery.periodid,
            subquery.programid) r ON s.district_name = r.district_name
AND s.region_name = r.region_name
AND s.facilitycode = r.facilitycode
AND s.periodid = r.periodid
AND s.programid = r.programid
GROUP BY s.region_name,
         s.district_name,
         s.status,
         s.programid,
         s.periodid,
         s.program,
         s.programname,
         s.facilitycode,
         s.facilitytypename,
         s.processing_period_name,
         s.asmonth,
         s.year,
         s.emergency,
         s.schedule,
         s.geo_iso,
         s.status2 WITH NO DATA;


ALTER materialized VIEW public.view_stock_imbalance_by_facility_report_aggregate OWNER TO postgres;

CREATE VIEW public.vw_requisition_timeliness_base AS
SELECT r.requisition_id,
       min(rsc.createddate) AS requisition_authorized_date,
       CASE
           WHEN COALESCE(date_part('day'::text, min(rsc.createddate::date::timestamp WITHOUT TIME ZONE) - r.period_end_date::timestamp WITHOUT TIME ZONE), 0::double precision) <= 21::double precision THEN 'R'::text
           WHEN COALESCE(date_part('day'::text, min(rsc.createddate::date::timestamp WITHOUT TIME ZONE) - r.period_end_date::timestamp WITHOUT TIME ZONE), 0::double precision) > 30::double precision THEN 'U'::text
           WHEN COALESCE(date_part('day'::text, min(rsc.createddate::date::timestamp WITHOUT TIME ZONE) - r.period_end_date::timestamp WITHOUT TIME ZONE), 0::double precision) > 21::double precision THEN 'L'::text
           ELSE 'N'::text
       END AS requisition_reporting_status
FROM vw_requisition_information r
JOIN kafka_status_changes rsc ON rsc.requisitionid = r.requisition_id
AND rsc.status = 'AUTHORIZED'::text
WHERE (r.requisition_status = ANY (ARRAY ['AUTHORIZED'::character varying::text, 'IN_APPROVAL'::character varying::text, 'APPROVED'::character varying::text, 'RELEASED'::character varying::text, 'RELEASED_WITHOUT_ORDER'::character varying::text]))
  AND r.facility_enabled = TRUE
  AND r.requisition_is_emergency = FALSE
GROUP BY r.requisition_id,
         r.period_end_date;


ALTER TABLE public.vw_requisition_timeliness_base OWNER TO postgres;


CREATE VIEW public.vw_requisition_timeliness AS
SELECT r.requisition_id,
       r.requisition_created_date,
       r.requisition_is_emergency,
       r.requisition_status,
       r.program_id,
       r.program_code,
       r.program_name,
       r.period_id,
       r.period_name,
       r.period_description,
       r.period_start_date,
       r.period_end_date,
       r.schedule_id,
       r.schedule_code,
       r.schedule_name,
       r.period_month,
       r.period_year,
       r.facility_id,
       r.facility_code,
       r.facility_name,
       r.facility_enabled,
       r.facility_description,
       r.facility_comment,
       r.facility_type_id,
       r.facility_type_code,
       r.facility_type_name,
       r.is_facility_type_primary_health_care,
       r.facility_type_nominal_max_month,
       r.zone1_id,
       r.zone1_code,
       r.zone1_name,
       r.zone1_iso_code,
       r.zone2_id,
       r.zone2_code,
       r.zone2_name,
       r.zone2_iso_code,
       r.level1_id,
       r.level1_code,
       r.level1_name,
       r.level2_id,
       r.level2_code,
       r.level2_name,
       r.is_initiated,
       r.is_submitted,
       r.is_skipped,
       r.is_authorized,
       r.is_in_approval,
       r.is_approved,
       r.is_released,
       rt.requisition_authorized_date,
       rt.requisition_reporting_status,
       CASE
           WHEN rt.requisition_reporting_status = 'R'::text THEN 1
           ELSE 0
       END AS r,
       CASE
           WHEN rt.requisition_reporting_status = 'L'::text THEN 1
           ELSE 0
       END AS l,
       CASE
           WHEN rt.requisition_reporting_status = 'U'::text THEN 1
           ELSE 0
       END AS u,
       CASE
           WHEN rt.requisition_reporting_status = 'N'::text THEN 1
           ELSE 0
       END AS n,
       CASE
           WHEN rt.requisition_reporting_status = 'R'::text THEN 'On Time'::text
           WHEN rt.requisition_reporting_status = 'L'::text THEN 'Late'::text
           WHEN rt.requisition_reporting_status = 'U'::text THEN 'Unscheduled'::text
           WHEN rt.requisition_reporting_status = 'N'::text THEN 'Not Reported'::text
           ELSE 'Unknown'::text
       END AS requisition_reporting_description
FROM vw_requisition_timeliness_base rt
JOIN vw_requisition_information r ON rt.requisition_id = r.requisition_id;

ALTER TABLE public.vw_requisition_timeliness OWNER TO postgres;