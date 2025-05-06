# Gettext

Gettext est un outil de localisation permettant d'extraire notre texte et de fournir directement toutes les traductions grâce à un système de fichiers ingénieux

## Setup

On vient ajouter gettext à la liste des dépendances

```elixir
      {:gettext, "~> 0.26"},
```

Puis, on vient créer un module `Gettext` dans `lib/ig_intranet_web/gettext.ex`

```elixir
defmodule IgIntranetWeb.Gettext do
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


### Traductions dynamiques avec interpolation
Parfois, une phrase contient une variable, comme un prénom ou un chiffre, que l’on souhaite intégrer dynamiquement dans la traduction. Dans ce cas, on utilise la fonction gettext/2 avec une interpolation. On vient passer une map contenant les valeurs à insérer dans la chaîne. Par exemple :

```elixir

{gettext("Hello %{name}", name: "Alice")}

```

Cela affichera : Hello Alice (ou Bonjour Alice si une traduction française existe). Il est important de conserver exactement les mêmes clés `(%{name})` entre la chaîne originale et la traduction dans les fichiers .po.


### Gestion du pluriel

On vient utiliser une balise légèrement différente quand une phrase peut être au singulier ou au pluriel en fonction d'une variable

```elixir
{ngettext("This is one example", "These are {%count} examples", 2)}
```

Cela génèrera un bloc dans `default.po` qui aura cette tête :

```elixir
msgid "You have one message"
msgid_plural "You have %{count} messages"
msgstr[0] ""
msgstr[1] ""
```

A noter que pour les langues bizarres comme le Russe qui a deux formes de pluriel possible, on peut ajouter des éléments au tableau msgstr[].


### Ajout de traduction pour les erreurs ou validations

Les messages d’erreur générés par Ecto (par exemple lors de la validation d’un formulaire) peuvent aussi être traduits. Pour cela, on utilise la fonction dgettext/2 avec un domaine spécifique, souvent "errors", pour bien organiser les traductions dans un fichier à part. Par exemple :

```elixir
add_error(changeset, :email, dgettext("errors", "must be a valid email"))
```

On pourra ensuite définir la traduction de ce message dans le fichier priv/gettext/fr/LC_MESSAGES/errors.po. Cela permet d’avoir des erreurs traduites automatiquement en fonction de la locale active.


### Utiliser dgettext/2 pour des domaines spécifiques

Par défaut, gettext/1 ou ngettext/3 utilisent le domaine default, mais il est tout à fait possible de créer des domaines de traduction spécifiques pour mieux organiser les chaînes, comme "flash", "errors", "auth", etc. Pour cela, on utilise la fonction dgettext/2, qui prend en premier argument le nom du domaine. Par exemple :

```elixir

{dgettext("flash", "You have been logged out")}
```

Ce message sera alors recherché dans le fichier flash.po de la langue active. Cela permet de structurer ses fichiers de traduction de façon plus claire et maintenable à mesure que le projet grossit.

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

### Le problème

Pour permettre à une application d'être bien référencée, la génération d'une live commence toujours pas l'affichage d'une page statique, puis une page dynamique est générée. C'est au moment de la génération de cette page dynamique que nos paramètres de traduction sont écrasés.

### La solution

Ici, nous choisirons d'aller cherche le comportement des live_views définies dans le fichier `ig_intranet_web.ex`qui est le fichier contenant la logique métier du projet global. Ici, les live_views sont définies par

``` elixir
def live_view do
...
end
```

et leur comportement sera appelée sur les lives grâce à cette ligne de code :

```elixir
 use IgIntranetWeb, :live_view
```

Note : C'est un choix d'implémenter cette logique métier à ce niveau global car cela nous permet de factoriser ce comportement et de l'appliquer à toutes les live_views de notre projet. Il aurait été tout à fait possible de les implanter à un niveau plus profond, pour n'affecter que certaines pages.

#### Implémenter un plug

```elixir
defmodule IgIntranetWeb.LiveLocale do
  @locales Gettext.known_locales(IgIntranetWeb.Gettext)

  def on_mount(:default, %{"locale" => locale}, _session, socket) when locale in @locales do
    Gettext.put_locale(IgIntranetWeb.Gettext, locale)
    {:cont, socket}
  end

  def on_mount(:default, _params, session, socket) do
    Gettext.put_locale(IgIntranetWeb.Gettext, session["locale"])
    {:cont, socket}
  end
```

On remarque que ce plug est très similaire au plug utilisé pour les pages statiques, à la différence qu'il est appelé grâce à la fonction `on_mount\4`

Cette fonction sera appelé au premier mount statique, et au second mount dynamique, après la création de la socket.

En utilisant le pattern matching, on peut gérer des mount dans les cas différents. Ici, on vient d'abord vérifier si un paramètre `locale` est passé au mount, et s'il appartient à la liste des locales disponibles de Gettext (@locales), on vient la définir comme locale actuelle.

```elixir
  @locales Gettext.known_locales(IgIntranetWeb.Gettext)

  def on_mount(:default, %{"locale" => locale}, _session, socket) when locale in @locales do
    Gettext.put_locale(IgIntranetWeb.Gettext, locale)
    {:cont, socket}
  end
```

Si aucun paramètre locale n'est passé, on vient vérifier si on en a pas déjà un de stocké dans la session, et on vient le récupérer dans notre live (par exemple, si on change de live, le paramètre disparaitra de l'URL mais on pourra le récupérer dans la session pour que notre site continue d'être traduit pendant toute la session)

```elixir
  def on_mount(:default, _params, session, socket) do
    Gettext.put_locale(IgIntranetWeb.Gettext, session["locale"])
    {:cont, socket}
  end
```


#### Appeler ce plug

Dans `ig_intranet_web.ex` qui gère la logique métier globale de notre projet, on vient appeler notre module au mount de nos lives


```elixir
  def live_view do
    quote do
      use Phoenix.LiveView,
        layout: {IgIntranetWeb.Layouts, :app}

      # On ajoute cette ligne pour appeler notre module
      on_mount IgIntranetWeb.LiveLocale
      unquote(html_helpers())
    end
  end
```
