# Bank YNAB importer [![Docker Build Statu](https://img.shields.io/docker/pulls/schurig/ynab-bank-importer.svg)](https://hub.docker.com/r/schurig/ynab-bank-importer/) [![Docker Build Statu](https://img.shields.io/docker/build/schurig/ynab-bank-importer.svg)](https://hub.docker.com/r/schurig/ynab-bank-importer/builds/) [![Maintainability](https://api.codeclimate.com/v1/badges/4367cde9c1b522b4bcbe/maintainability)](https://codeclimate.com/github/schurig/ynab-bank-importer/maintainability)

This is a ruby script that **pulls your transactions from your banks** and imports them into **You Need A Budget** (YNAB).

**Mission:** A script that can run every 15 minutes on a small and cheap mini-computer at your home (eg. raspberry pi) with an easy configuration and support for most European banks.

**Documentation:**

* [How to setup](https://github.com/schurig/ynab-bank-importer/wiki#ways-to-set-up-the-script)
* [Frequently asked questions (FAQ)](https://github.com/schurig/ynab-bank-importer/wiki/faq)

---

## Disclaimer

**Using this tool is on your own risk.** I can **not** garantee you that this will work for you. Also I can **not** garantee that it won't up your YNAB data. I highly recommend to start with a new Budget or at least test it with a new one before you use your existing Budget.

---

## Supported banks

* Most German and Austrian banks _(all banks that implement the FinTS standard)_
* BBVA Spain _(private accounts only)_
* N26
* PSD2 Banks via SaltEdge API (tested with German bank: DKB)

**💡 Check out the [configuration guides for the dumpers and banks](https://github.com/schurig/ynab-bank-importer/wiki#supported-dumpers)**.

## Why

YNAB only supports U.S. and Canadian Banks for now.

# Technical details on how it works

The script fetches the transaction information from your bank(s). Then it uses the official YNAB API to create the transactions for you.

The script also includes some additional logic like detecting internal transactions by checking if the account transactions go to or come from is one of the other accounts that you set up in the config _(of course this only works if you have multiple accounts configured)_.

# Known Problems

* Please read the notes in each Dumper _[(see Wiki)](https://github.com/schurig/ynab-bank-importer/wiki#supported-dumpers)_ to understand the limitations

____________________

# Support / Contribution

Support and contriubution of any kind is always welcome!!!

# Thanks

* [@dequis](https://github.com/dequis) for preventing the script from failing in the future [PR #70](https://github.com/schurig/ynab-bank-importer/pull/70) and keeping an eye on the development experience [PR #69](https://github.com/schurig/ynab-bank-importer/pull/69)
* [@moay](https://github.com/moay), [@yuvke](https://github.com/yuvke), [@BluetriX](https://github.com/BluetriX) for the help on debugging an error with not existing dates [Issue #52](https://github.com/schurig/ynab-bank-importer/issues/52)
* [@mathijshoogland](https://github.com/mathijshoogland) for updating the dependencies [PR #49](https://github.com/schurig/ynab-bank-importer/pull/49)
* [@manuelgrabowski](https://github.com/manuelgrabowski), [@martinlabuschin](https://github.com/martinlabuschin) and [@peterjeschke](https://github.com/peterjeschke) for giving feedback on a new N26 dumper config flag that prevents transactions to be imported multiple times [PR #38](https://github.com/schurig/ynab-bank-importer/pull/38)
* [@peterjeschke](https://github.com/peterjeschke) for fixing a bug that happened when the FinTS username was an integer [PR #35](https://github.com/schurig/ynab-bank-importer/pull/35)
* [@derintendant](https://github.com/derintendant) for spotting and fixing edge cases [PR #27](https://github.com/schurig/ynab-bank-importer/pull/27) (improves error messages) and [PR #28](https://github.com/schurig/ynab-bank-importer/pull/28) (truncates the payee field if it's too long)
* [@manuelgrabowski](https://github.com/manuelgrabowski) for implementing a fallback in the FinTS dumper [PR #26](https://github.com/schurig/ynab-bank-importer/pull/26)
* [@markuspabst](https://github.com/markuspabst) for spotting an error in the readme [PR #11](https://github.com/schurig/ynab-bank-importer/pull/11)
* [@wizonesolutions](https://github.com/wizonesolutions) for giving feedback on the N26 integration [PR #9](https://github.com/schurig/ynab-bank-importer/pull/9)
* [@mkilling](https://github.com/mkilling) for writing the [FinTS ruby lib](https://github.com/playtestcloud/ruby_fints) that I'm using & helping me fixing a bug
* you for reading this
