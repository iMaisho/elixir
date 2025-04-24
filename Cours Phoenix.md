# Structure d'un projet

# LiveView

L'appel à une LiveView commence par une simple requête HTTP afin de récupérer tout le contenu statique de la page. Cela garantit un affichage rapide, même sans JS.

Puis, une websocket est créée pour lier le contenu dynamique aux données transmises par le serveur.

A chaque fois que ces données sont modifiées, une WebSocket est ouverte, permettant au serveur d’envoyer dynamiquement les changements de données au client. Seules les parties modifiées du DOM sont mises à jour.

## Fonctions de reredering

Pour appliquer les modifications à la page Web, 3 fonctions sont appelées successivement :

### `mount\3` : `(params, session, socket)`

Cette fonction permet de modifier les assignations de sockets utiles aux rerendering.
- `params` est une map de string keys qui contient les données publiques pouvant être modifiées par l'utilisateur (ex : filtres).
 The map contains the query params as well as any router path parameter. If the LiveView was not mounted at the router, this argument is the atom `:not_mounted_at_router`


- `session` contient les données privées, gérées par l'application (ID utilisateur, droits, token...)

### `handle_params\3` : `(params, uri, socket)`

Appelée à chaque fois que l'URL change (via `live_patch` par exemple), cette fonction permet de réagir aux nouveaux paramètres sans recharger toute la LiveView.
On s’en sert souvent pour charger dynamiquement du contenu selon les paramètres de l’URL.

**Note :** `handle_params` is only allowed on LiveViews mounted at the router, as it takes the current url of the page as the second parameter.

### `render\1` : (assigns)

Enfin, la fonction render retourne un template HEEx, qui est ensuite diffé côté serveur, et seul le contenu modifié est envoyé au client sous forme d'HTML statique.

**Ce cycle assure une interface réactive, performante, et presque entièrement pilotée côté serveur – sans JavaScript personnalisé nécessaire.**


## Définition des templates

Il y a deux moyens de créer un template dynamique dans Phoenix :

### Pour les templates complexes : Création d'un fichier `HEEx`

Afin que ces templates soient directement linkés à notre LiveView, il suffit de les placer dans le même répertoire, avec le même nom. Seule l'extension change : le fichier LiveView est en `.ex`, tandis que le template associé est en `.html.heex`.

### Pour les templates d'éléments simples : Utilisation de `~H`

Dans notre LiveView, on peut directement définir une fonction `render(assigns)` qui retournera un bloc HTML statique, contenant une logique Elixir dynamique.

Pour cela, on utilise la syntaxe suivante :

```Elixir
def render(assigns) do
  ~H"""
    ...
  """
end
```

`~H"""` est une sigil spéciale fournie par Phoenix pour écrire du HTML enrichi de logique Elixir (comme les if, for, etc.) directement dans le code.

### Contenu dynamique : les `assigns`

Toutes les données d'une LiveView sont stockées dans le `socket`, une `Struct` côté serveur appelée par `Phoenix.Liveview.Socket`.

Les données que l'on utilise sont stockées dans la clé `assigns`de cette struct.

#### Stocker et accéder aux données

Afin de stocker des données dans le socket, on utilise la fonction `Phoenix.Component.assign`.
Il existe deux versions de cette méthode :

- `Phoenix.Component.assign\2` : `(socket_or_assign, keyword_or_map)` permet de stocker une map ou une keywordlist dans `assigns`

- `Phoenix.Component.assign\3`: `(socket_or_assign, key, value)`permet de stocker une paire clé/valeur dans `assigns`

Dans le contexte d’une LiveView, on utilise généralement `assign\2 ou 3` directement (importé depuis Phoenix.LiveView ou Phoenix.Component), pas besoin de le préfixer dans la majorité des cas.

Pour accéder aux données dans la LiveView, on utilise `socket.assigns.name`

Dans un template `.heex`, les assignations sont disponibles sous forme de variables préfixées par `@`. Par exemple, `@name`, `@user`, etc.

### Best Practices : Les templates

- A l'exception des variables déclarées dans des blocks `case`, `for` ou `if` par exemple, **les variables déclarées dans les templates ne sont pas trackées par LiveView**, et ne seront donc pas mises à jour lorsque modifiées.
Pour contourner ce problème, on utilisera des fonctions.

```elixir
# Ne pas faire
<% some_var = @x + @y %>
{some_var}

# Utiliser une fonction à la place
{sum(@x, @y)}
```

- **Spécifier les clés de `assigns` dont on a besoin dand un élément** : Si on passe assigns à tous les éléments de notre composant, il sera regénéré en intégralité à chaque fois qu'une des données sera modifiée. Si, au contraire, on le divise en plusieurs éléments indépendants, chacun de ces éléments sera rerender indépendemment

```elixir

# Ne pas faire
def card(assigns) do
  ~H"""
  <div class="card">
    <.card_header {assigns} />
    <.card_body {assigns} />
    <.card_footer {assigns} />
  </div>
  """
end

defp card_header(assigns) do
  ...
end

defp card_body(assigns) do
  ...
end

defp card_footer(assigns) do
  ...
end


# Préciser chaque clé de assign dont l'élément a besoin

def card(assigns) do
  ~H"""
  <div class="card">
    <.card_header title={@title} class={@title_class} />
    <.card_body>
      {render_slot(@inner_block)}
    </.card_body>
    <.card_footer on_close={@on_close} />
  </div>
  """
end
```

## Opérations asynchrones
