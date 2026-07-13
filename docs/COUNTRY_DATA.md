# Country data

## Playable scope

The app contains 197 playable countries:

- 193 UN member states;
- the two UN observer states, the Holy See/Vatican City and Palestine;
- Taiwan;
- Kosovo.

The raw localized `countries.json` files contain 250 country and territory rows,
including non-playable territories. `continents.json` is the source of truth for
the 197-country gameplay pool. Palestine, Taiwan and Kosovo are appended after
the original 194 entries in every level file to preserve existing save indexes.

## Data policy and sources

- Localized country and currency names follow [Unicode CLDR](https://cldr.unicode.org/), with the shorter product name `Palestine` used instead of CLDR's territory label. A few CLDR display abbreviations and parenthetical aliases are expanded to their full localized names because punctuation such as `&` and parentheses would otherwise become playable letter tiles.
- Current currency codes follow [SIX's ISO 4217 data](https://www.six-group.com/en/products-services/financial-information/market-reference-data/data-standards.html). The one-value UI uses ILS for Palestine, EUR for Kosovo and TWD for Taiwan.
- Continent assignments follow [UN M49](https://unstats.un.org/unsd/methodology/m49/overview/): Armenia, Cyprus, Georgia, Palestine and Taiwan are in Asia; Russia and Kosovo are in Europe.
- Equatorial Guinea uses `Ciudad de la Paz`, declared the capital by [Decree-Law 1/2026](https://www.guineaecuatorialpress.com/index.php/noticias/decreto_ley_por_el_que_se_declara_la_ciudad_de_la_paz_djibloho_capital_de_la_republica_de_guinea_ecuatorial).
- Bolivia lists both `Sucre` and `La Paz`: [Article 6 of Bolivia's Constitution](https://www.silep.gob.bo/norma/12928/ley_actualizada) names Sucre as the capital, while a [UN state report](https://documents.un.org/doc/undoc/gen/g07/416/23/pdf/g0741623.pdf?OpenElement) identifies La Paz as the seat of government.
- Brazil uses the proper place name `Brasília`, including the diacritic, in every locale.
- South Africa lists all three functional capitals. Palestine lists East Jerusalem and the administrative centre Ramallah because one short capital field cannot fully express the status distinction.

The Kosovo map assets (`xk.png` and `xk-full.png`) are original project assets
created by Jackie Hartvig. Attribution for the supplemented Taiwan emblem is
documented in `docs/THIRD_PARTY_ASSETS.md`.
