# Bank YNAB importer [![Docker Build Statu](https://img.shields.io/docker/pulls/schurig/ynab-bank-importer.svg)](https://hub.docker.com/r/schurig/ynab-bank-importer/) [![Docker Build Statu](https://img.shields.io/docker/build/schurig/ynab-bank-importer.svg)](https://hub.docker.com/r/schurig/ynab-bank-importer/builds/) [![Maintainability](https://api.codeclimate.com/v1/badges/4367cde9c1b522b4bcbe/maintainability)](https://codeclimate.com/github/schurig/ynab-bank-importer/maintainability)

This is a ruby script that **pulls your transactions from your banks** and imports them into **You Need A Budget** (YNAB).

## Supported banks

* Most German and Austrian banks _(all banks that implement the FinTS standard)_
* BBVA Spain _(private accounts only)_
* N26

## Why

YNAB only supports U.S. and Canadian Banks for now.

_If you're someone from the YNAB-Team: please add a public api-endpoint for an easier import of transactions. ❤️_

## Usage

**If you clone this repository you don't need to follow step 2!**

1. Install docker and docker-compose

2. Create a `docker-compose.yml` file with [this content](https://raw.githubusercontent.com/schurig/ynab-bank-importer/master/docker-compose.yml)

3. Create a `config.yml`

```yaml
---
ynab:
  access_token: # ynab access token
  budget_id: # budget_id
  cash_account_id: # optional
accounts:
  - dumper: :n26
    iban: # iban of your n26
    ynab_id: # account id in YNAB
    username: # email
    password: # password
```

_Example: [`config.sample.yml`](https://github.com/schurig/ynab-bank-importer/blob/master/config.sample.yml)_

3. `docker-compose pull ruby && docker-compose run ruby`

## Dumpers

### FinTS / HBCI `:fints`

The FinTS / HBCI standard is mainly implemented by German banks.

#### Options

* `fints_endpoint` _(required)_

> The endpoint is the url which is needed to communicate with your bank to fetch the recent transactions. You can find it out [here](https://www.hbci-zka.de/institute/institut_auswahl.htm) (use the PIN/TAN URL from the link).

* `fints_blz` _(required)_

> This is the routing number / Bankleitzahl of your bank. You can find it out on the bank's website.

#### Notes

* Currently tested with **DKB** and **ING-DiBa**.
* **!!! If you change your online banking password** please don't run the importer with the wrong password. Your bank might lock your account if there are too many failed login attempts.
* It currently fetches the transactions from the last 35 days. Please open an issue or PR if you want to change this.

### N26 `:n26`

`memo` is a combination of the reference text and the city of the transaction provided by N26.

#### Note

* It currently only fetches the last 100 transactions. Please open an issue or PR if you want to change this.

#### Options

* `set_category` _(default: false)_

> Set the transaction category to the N26 category. Only makes sense if you have the N26 categories set up in your YNAB.

### BBVA `:bbva`

The field `payee` will be `N/A` because we currently don't get the payee name.

# Technical details on how it works

On [app.youneedabudget.com](https://app.youneedabudget.com) you can upload a `.csv` file with your transactions. The structure looks like this:

```csv
Date,Payee,Category,Memo,Outflow,Inflow
2017-08-13,METRO BARCELONA,Transport & Car,Ticket for the Beach,"",-9.95
```

*So we need this information for each transaction:*

* Date _(YYYY-MM-DD)_
* Payee
* Category _(optional)_
* Outflow _(optional *if `Inflow` also uses negative numbers*)_
* Inflow

The script fetches the transaction information from your bank and puts it into the format mentioned above.
It exports the result of each individual account in a file. Then it uses selenium-webdriver Chrome to login to your YNAB account, navigates to the right account and imports it for you.

____________________

# Support / Contribution

Support and contriubution of any kind is always welcome!!!

I'm not that into hardware. It would be super awesome if someone could help making this work on Raspbian. I already tried but building the docker container fails _(Dockerfile-rpi)_.

# Thanks

* [@mkilling](https://github.com/mkilling) for writing the [FinTS ruby lib](https://github.com/playtestcloud/ruby_fints) that I'm using & helping me fixing a bug
* you for reading this
