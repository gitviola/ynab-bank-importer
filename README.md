# Bank YNAB importer [![Docker Build Statu](https://img.shields.io/docker/pulls/schurig/ynab-bank-importer.svg)](https://hub.docker.com/r/schurig/ynab-bank-importer/) [![Docker Build Statu](https://img.shields.io/docker/build/schurig/ynab-bank-importer.svg)](https://hub.docker.com/r/schurig/ynab-bank-importer/builds/) [![Maintainability](https://api.codeclimate.com/v1/badges/4367cde9c1b522b4bcbe/maintainability)](https://codeclimate.com/github/schurig/ynab-bank-importer/maintainability)

This is a ruby script that **pulls your transactions from your banks** and imports them into **You Need A Budget** (YNAB).

**Mission:** A script that can run every 15 minutes on a small and cheap mini-computer at your home (eg. raspberry pi) with an easy configuration and support for most European banks.

**Documentation:**

* [How to setup](https://github.com/schurig/ynab-bank-importer/wiki#ways-to-set-up-the-script)
* [Frequently asked questions (FAQ)](https://github.com/schurig/ynab-bank-importer/wiki/faq)

---

## Supported banks

* Most German and Austrian banks _(all banks that implement the FinTS standard)_
* BBVA Spain _(private accounts only)_
* N26

**💡 Check out the [configuration guides for the dumpers and banks](https://github.com/schurig/ynab-bank-importer/wiki#supported-dumpers)**.

## Why

YNAB only supports U.S. and Canadian Banks for now.

# Technical details on how it works

The script fetches the transaction information from your bank(s). Then it uses the official YNAB API to create the transactions for you.

The script also includes some additional logic like detecting internal transactions by checking if the account transactions go to or come from is one of the other accounts that you set up in the config _(of course this only works if you have multiple accounts configured)_.

# Known Problems

* Internal transactions _(transfer from one account to an other one)_ don't work yet. This is because the official YNAB API doesn't support the creation of internal transactions yet.

> **Workaround:** the script flags those transactions in orange, so you can quickly see them and manually edit them to be an internal transaction.

* With N26 it could import a transactions twice from time to time. This is a problem on N26's side, because they change the id of the transaction sometimes.

> **Workaround:** when you see a transaction showing up twice, you can discard it. It's easy to spot because the payee, date and the price are usually the same. We're working on a solution here: [#16](https://github.com/schurig/ynab-bank-importer/pull/16).

____________________

# Support / Contribution

Support and contriubution of any kind is always welcome!!!

I'm not that into hardware. It would be super awesome if someone could help making this work on Raspbian. I already tried but building the docker container fails _(Dockerfile.rpi)_. The PR related to that you can find here: [18](https://github.com/schurig/ynab-bank-importer/pull/18)

# Thanks

* [@mkilling](https://github.com/mkilling) for writing the [FinTS ruby lib](https://github.com/playtestcloud/ruby_fints) that I'm using & helping me fixing a bug
* [@wizonesolutions](https://github.com/wizonesolutions) for giving feedback on the N26 integration and [PR #9](https://github.com/schurig/ynab-bank-importer/pull/9)
* you for reading this
