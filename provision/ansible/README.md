## Ansible Dependencies

In order to successfully run the Ansible scripts defined herein, you'll need to install the required package dependencies. Do this using the following commands:

Install the pip dependencies. You'll need to have python-pip installed on your deployment machine. Though not required, it's recommended you run the following command inside a [Python virtualenv](https://virtualenvwrapper.readthedocs.io/en/latest/):

```sh
pip install -r requirements/ansible.pip
```

Install the [Ansible Galaxy](https://galaxy.ansible.com/docs/) dependencies:

```sh
mkdir -p vendor/roles
ansible-galaxy install -p vendor/roles -r requirements/galaxy.yml
```
