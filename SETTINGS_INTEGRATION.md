# Settings integration

- Use `AppTheme.withTypography(existingTheme)` from `lib/theme/app_theme.dart`
  to add the shared typography to MaterialApp while preserving its colors.
- At startup, await `CurrencyPreferences.load()` before displaying expense
  amounts. Ensure Flutter bindings are initialized before reading preferences.
- Wrap amount displays in a `ValueListenableBuilder<ExpenseCurrency>` with
  `CurrencyPreferences.current` so the display updates when Settings saves a
  preference. Format each amount with `currency.format(amount)`. Pass the
  interface locale if the app supplies one. The helper leaves amounts unchanged.
- Settings already uses the existing ExpenseProvider. It locks currency while
  the provider has expenses or is still loading. No new root provider is needed.

Roboto Mono is bundled with its license. The About illustration is
[Twemoji](https://github.com/twitter/twemoji), © Twitter, Inc. and contributors,
licensed under [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/).
