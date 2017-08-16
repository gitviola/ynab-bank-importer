# Bank YNAB importer

This is a ruby script that **pulls your transactions from your banks** and imports them into **You Need A Budget** (YNAB).

## Supported banks

* Most German and Austrian banks _(all banks that [figo.io](https://figo.io) supports)_
* BBVA Spain _(private accounts only)_
* N26

## Why

YNAB only supports U.S. and Canadian Banks for now.

_If you're someone from the YNAB-Team: please add a public api-endpoint for an easier import of transactions. ❤️_

## Usage

1. Install docker

2. Create a `config/config.yml`

```yaml
---
ynab:
  username: # email
  password: # password
  budget_id: # budget_id
accounts:
  - dumper: :n26
    iban: # iban of your n26
    ynab_id: # account id on YNAB
    username: # email
    password: # password
```

_Example: [`config/config.sample.yml`](#)_

3. `docker-compose build ruby && docker-compose run ruby`

## Dumpers

### N26 `:n26`

Sets the name of the transaction's category as `memo`.

### BBVA `:bbva`

The field `payee` will be `N/A` because we currently don't get the payee name.

### Figo `:figo`

You need to get a [figo.io](https://figo.io) account first.

Since there is a high chance that you use the `:figo` dumper more than once, all transactions from figo will be downloaded once and be cached thoughout the run.
_If you want to turn off this behavior add the option `force_download: true`._

## Wishlist

- [ ] Only fetch transactions from specific date on
- [ ] Check if transaction is to or from any of the owner's accounts: set `payee` to `Transfer : %ACCOUNT NAME ON YNAB%` _(also make sure that this doesn't create duplicates)_
- [ ] Make docker-container Raspberry Pi compatible so that it can run periodically.
- [ ] BBVA: find out the Payee and Memo of the transaction
- [ ] N26: option `skip_category` to not set the N26 category for that transaction _(useful if you have your own. Also YNAB auto-detects the category after a while)_
- [ ] **!!** Not use selenium webdriver anymore _(rather use APIs)_

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
