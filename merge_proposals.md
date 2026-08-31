# Návrhy na sloučení projektů

Na základě klíčových slov v názvech byly identifikovány následující skupiny projektů, které by mohly být sloučeny.

## Skupina: template
- Projekty: containers-template
- Doporučení: Zvážit sloučení do jednoho adresáře nebo vytvoření společné knihovny.

## Skupina: installer
- Projekty: md-installer, starcore-installer, ultimate-raspberry-pi-5-all-in-one-installer
- Doporučení: Zvážit sloučení do jednoho adresáře nebo vytvoření společné knihovny.

## Skupina: codespace
- Projekty: universal-ai-codespace
- Doporučení: Zvážit sloučení do jednoho adresáře nebo vytvoření společné knihovny.

## Skupina: workspace
- Projekty: starcore-workspace, starko-rpi5-ai-workspace
- Doporučení: Zvážit sloučení do jednoho adresáře nebo vytvoření společné knihovny.

## Skupina: builder
- Projekty: starcore-auto-builder-v3-0-live-dashboard
- Doporučení: Zvážit sloučení do jednoho adresáře nebo vytvoření společné knihovny.


## Obecné doporučení
- Pro workspace/codespace projekty: vytvořit jednotnou šablonu v `templates/` a využít devcontainer.
- Pro instalační skripty: centralizovat do `infrastructure/installers/`.
- Pro šablony: uchovávat v `templates/` a verzovat.

