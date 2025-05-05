# Gettext

Gettext est un outil de localisation permettant d'extraire notre texte et de fournir directement toutes les traductions grâce à un système de fichiers ingénieux

## Setup

On vient ajouter gettext à la liste des dépendances

```elixir
      {:gettext, "~> 0.26"},
```

Puis, on vient créer un module `Gettext` dans `lib/ig_intranet_web/gettext.ex`

```elixir
defmodule IgIntranet.Gettext do
  @moduledoc """

  """
  use Gettext.Backend, otp_app: :ig_intranet
end

```

Enfin, on vient ajouter une ligne dans notre fichier `config.exs`

```elixir
config :ig_intranet, IgIntranetWeb.Gettext, default_locale: "fr", allowed_locales: ["en", "fr"]
```

Si on ne la précise pas, la locale par défaut sera `en`.

## Utiliser Gettext

Pour utiliser gettext, on commence par ajouter des "balises" gettext autour des blocs de texte que l'on souhaite localiser.

Comme nous somme dans des HEEX, il faut utiliser des balises elixir `<%= %>` ou `{}`

```elixir
{gettext("This is an example")}
```

Par la suite, on vient jouer quelques commandes dans le terminal pour générer les fichiers de traduction :

### Extract
```bash
mix gettext.extract
```
Cette commande va parcourir nos fichiers à la recherche de la fonction gettext, et répertorier toutes les phrases dans un fichier `.pot` (`Portable Object Template`).

### Merge

```bash
mix gettext.merge priv/gettext
mix gettext.merge priv/gettext --locale fr
```

Ces commandes vont permettre de générer les fichiers `.po` à partir du template `.pot`, ou de les modifier s'ils existent déjà.

Ce sont ces fichiers dans lesquels nous viendrons écrire nos traductions.

## Structure d'un `.po`

`default.po` est le fichier de base de traduction. Il vient lister tous les messages que l'on souhaite traduire sous cette forme :

```bash
#: lib/ig_intranet_web/controllers/page_html/home.html.heex:56
#, elixir-autogen, elixir-format
msgid "Original message."
msgstr "Message traduit"
```

On a la position du message dans le projet, sa valeur d'origine qui sert également d'identifiant dans `msgid`, et sa traduction que l'on va directement pouvoir modifier dans `msgstr`.

A la génération de l'un de ces blocs, `msgstr` est initialisé à string vide `""`, et ne remplacera donc pas `msgid`

### Gestion du pluriel

On vient utiliser une balise légèrement différente quand une phrase peut être au singulier ou au pluriel en fonction d'une variable

```elixir
{ngettext("This is one example", "These are {%count} examples", 2)}
```

Cela génèrera un bloc dans `default.po` qui aura cette tête :

```elixir
msgid "Youmsgid "You have one message"
msgid_plural "You have %{count} messages"
msgstr[0] ""
msgstr[1] "" have one message"
msgid_plural "You have %{count} messages"
msgstr[0] ""
msgstr[1] ""
```

## Déclencher les traductions

Pour pouvoir dire à `GetText` dans quelle langue il faut traduire, on vient créer un `plug` qui sera ensuite appelé dans notre routeur.

```elixir
defmodule IgIntranetWeb.Plugs.Locale do
  @moduledoc """
  ....
  """
  import Plug.Conn

  @locales Gettext.known_locales(IgIntranetWeb.Gettext)
  def init(_opts), do: nil

  def call(%Plug.Conn{params: %{"locale" => locale}} = conn, _opts) when locale in @locales do
    Gettext.put_locale(IgIntranetWeb.Gettext, locale)
    conn
  end

  def call(conn, _opts), do: conn
end
```

### Explication de ce module

```elixir
  @locales Gettext.known_locales(IgIntranetWeb.Gettext)
```

→ On récupère la liste des langues (locales) supportées par l’app, définies via les fichiers `.po` de Gettext. Par exemple : `["en", "fr"]`. Elle est stockée dans un attribut de module `@locales`.


```elixir
  def init(_opts), do: nil
```

→ Fonction obligatoire dans un plug. Elle initialise les options du plug. Ici, elle ignore les options et retourne `nil`. (utile si on veut configurer son plug plus tard).

---

```elixir
  def call(%Plug.Conn{params: %{"locale" => locale}} = conn, _opts) when locale in @locales do
      Gettext.put_locale(IgIntranetWeb.Gettext, locale)
      conn
  end
```

→ Cette clause de la fonction `call/2` s’exécute **uniquement** si les paramètres de la requête (`params`) contiennent une clé `"locale"` **et** que sa valeur (`locale`) est dans la liste des locales supportées (`@locales`).Elle définit la locale active de Gettext (donc la langue utilisée dans les traductions) pour cette requête puis retourne la connexion inchangée, mais la locale est maintenant activée dans le contexte de la requête.


```elixir
  def call(conn, _opts), do: conn
```

→ Clause de secours : si aucun `locale` valide n'est présent dans les paramètres, on ne change rien et on passe simplement la requête à la suite du pipeline.

### Déclaration du plug dans le routeur

Dans la pipeline par laquelle passent les pages qui nous intéressent, on ajoute le plug que l'on vient de créer

```elixir
  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {IgIntranetWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug IgIntranetWeb.Plugs.Locale # Ajout de notre plug
  end
```


Et voilà ! En passant un paramètre de `locale` via notre URL (`?locale=fr`), notre page est automatiquement traduite !

Il en va de même pour nos lives qui... Attends quoi ?

Ma live a bien été traduite, mais une fraction de seconde plus tard elle est revenue à la langue par défaut... Bizzare

## Traduire une Live
