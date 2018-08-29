# Bank YNAB importer [![Docker Build Statu](https://img.shields.io/docker/pulls/schurig/ynab-bank-importer.svg)](https://hub.docker.com/r/schurig/ynab-bank-importer/) [![Docker Build Statu](https://img.shields.io/docker/build/schurig/ynab-bank-importer.svg)](https://hub.docker.com/r/schurig/ynab-bank-importer/builds/) [![Maintainability](https://api.codeclimate.com/v1/badges/4367cde9c1b522b4bcbe/maintainability)](https://codeclimate.com/github/schurig/ynab-bank-importer/maintainability)

This is a ruby script that **pulls your transactions from your banks** and imports them into **You Need A Budget** (YNAB).

**Mission:** A script that can run every 15 minutes on a small and cheap mini-computer at your home (eg. raspberry pi) with an easy configuration and support for most European banks.

## Supported banks

* Most German and Austrian banks _(all banks that implement the FinTS standard)_
* BBVA Spain _(private accounts only)_
* N26

**Check out the [configuration guides for the dumpers and banks](https://github.com/schurig/ynab-bank-importer/wiki#supported-dumpers)**

## Why

YNAB only supports U.S. and Canadian Banks for now.

## Example setup with docker

You will need to obtain a personal access token. [Here is a tutorial on how to do it](https://api.youneedabudget.com/#personal-access-tokens).

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

3. `docker-compose pull importer && docker-compose run importer`

**Check out the [guides to set up the script](https://github.com/schurig/ynab-bank-importer/wiki#ways-to-set-up-the-script)**.

# Technical details on how it works

The script fetches the transaction information from your bank(s). Then it uses the official YNAB API to create the transactions for you.

The script also includes some additional logic like detecting internal transactions by checking if the account transactions go to or come from is one of the other accounts that you set up in the config _(of course this only works if you have multiple accounts configured)_.

# Known Problems

* Internal transactions _(transfer from one account to an other one)_ don't work yet. This is because the official YNAB API doesn't support the creation of internal transactions yet. **Workaround:** the script flags those transactions in orange, so you can quickly see them and manually edit them to be an internal transaction.

* With N26 it could import a transactions twice from time to time. This is a problem on N26's side, because they change the id of the transaction sometimes. **Workaround:** when you see a transaction showing up twice, you can discard it. It's easy to spot because the payee, date and the price are usually the same.

____________________

# Support / Contribution

Support and contriubution of any kind is always welcome!!!

I'm not that into hardware. It would be super awesome if someone could help making this work on Raspbian. I already tried but building the docker container fails _(Dockerfile-rpi)_.

# Thanks

* [@mkilling](https://github.com/mkilling) for writing the [FinTS ruby lib](https://github.com/playtestcloud/ruby_fints) that I'm using & helping me fixing a bug
* [@wizonesolutions](https://github.com/wizonesolutions) for giving feedback on the N26 integration and [PR #9](https://github.com/schurig/ynab-bank-importer/pull/9)
* you for reading this
