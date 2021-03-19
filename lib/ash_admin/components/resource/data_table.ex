defmodule AshAdmin.Components.Resource.DataTable do
  use Surface.LiveComponent

  import AshAdmin.Helpers
  import AshPhoenix.LiveView
  alias AshAdmin.Components.Resource.DestroyModal
  alias Surface.Components.LiveRedirect
  alias AshAdmin.Components.Resource.Table

  prop(resource, :atom)
  prop(api, :atom)
  prop(action, :any)
  prop(authorizing, :boolean)
  prop(set_actor, :event, required: true)
  prop(actor, :any)

  data(initialized, :boolean, default: false)
  data(data, :any)

  def update(assigns, socket) do
    if assigns[:initialized] do
      {:ok, socket}
    else
      socket = assign(socket, assigns)

      socket =
        if assigns[:action].pagination do
          keep_live(
            socket,
            :data,
            fn socket, page_opts ->
              assigns[:api].read(socket.assigns[:resource],
                action: socket.assigns[:action].name,
                actor: socket.assigns[:actor],
                authorize?: socket.assigns[:authorizing],
                page: page_opts || []
              )
            end,
            load_until_connected?: true
          )
        else
          keep_live(
            socket,
            :data,
            fn socket ->
              assigns[:api].read(socket.assigns[:resource],
                action: socket.assigns[:action],
                actor: socket.assigns[:actor],
                authorize?: socket.assigns[:authorizing]
              )
            end,
            load_until_connected?: true
          )
        end

      {:ok,
       socket
       |> assign(:initialized, true)}
    end
  end

  def render(assigns) do
    ~H"""
    <div class="h-full mt-8 overflow-scroll">
      <div :if={{ match?({:error, _}, @data) }}>
        {{ {:error, %{query: query}} = @data
        nil }}
        <ul>
          <li :for={{ error <- query.errors }}>
            {{ message(error) }}
          </li>
        </ul>
      </div>
      <Table :if={{ match?({:ok, _data}, @data) }} data={{data(@data)}} resource={{@resource}} api={{@api}} set_actor={{@set_actor}}/>
    </div>
    """
  end

  defp message(error) do
    if is_exception(error) do
      Exception.message(error)
    else
      inspect(error)
    end
  end

  #  defp middle_page_num(num, trailing_page_nums) do
  #     if num in trailing_page_nums || num <= 3 do
  #       "..."
  #     else
  #       "...#{num}..."
  #     end
  #   end

  #   defp page_link_params({:ok, page}, target), do: page_link_params(page, target)

  #   defp page_link_params(page, target) do
  #     case AshPhoenix.LiveView.page_link_params(page, target) do
  #       :invalid ->
  #         nil

  #       params ->
  #         [page: params]
  #     end
  #   end

  #   defp show_ellipses?(%Ash.Page.Offset{count: count, limit: limit}) when not is_nil(count) do
  #     page_nums =
  #       count
  #       |> Kernel./(limit)
  #       |> Float.ceil()
  #       |> trunc()

  #     page_nums > 6
  #   end

  #   defp show_ellipses?({:ok, data}), do: show_ellipses?(data)
  #   defp show_ellipses?(_), do: false

  #   def leading_page_nums({:ok, data}), do: leading_page_nums(data)
  #   def leading_page_nums(%Ash.Page.Offset{count: nil}), do: []

  #   def leading_page_nums(%Ash.Page.Offset{limit: limit, count: count}) do
  #     page_nums =
  #       count
  #       |> Kernel./(limit)
  #       |> Float.ceil()
  #       |> trunc()

  #     1..min(3, page_nums)
  #   end

  #   def leading_page_nums(_), do: []

  #   def trailing_page_nums({:ok, data}), do: trailing_page_nums(data)
  #   def trailing_page_nums(%Ash.Page.Offset{count: nil}), do: []

  #   def trailing_page_nums(%Ash.Page.Offset{limit: limit, count: count}) do
  #     page_nums =
  #       count
  #       |> Kernel./(limit)
  #       |> Float.ceil()
  #       |> trunc()

  #     if page_nums > 3 do
  #       max(page_nums - 2, 0)..page_nums
  #     else
  #       []
  #     end
  #   end

  #   def handle_event("toggle_filter", _, socket) do
  #     {:noreply, assign(socket, :filter_open, !socket.assigns.filter_open)}
  #   end

  defp data({:ok, data}), do: data(data)
  defp data({:error, _}), do: []
  defp data(%Ash.Page.Offset{results: results}), do: results
  defp data(%Ash.Page.Keyset{results: results}), do: results
  defp data(data), do: data

  #   defp offset?({:ok, data}), do: offset?(data)
  #   defp offset?(%Ash.Page.Offset{}), do: true
  #   defp offset?(_), do: false

  #   defp keyset?({:ok, data}), do: keyset?(data)
  #   defp keyset?(%Ash.Page.Keyset{}), do: true
  #   defp keyset?(_), do: false

  #   defp offset({:ok, data}), do: offset(data)
  #   defp offset(%Ash.Page.Offset{offset: offset}), do: offset
  #   defp offset(_), do: 0

  #   defp limit({:ok, data}), do: limit(data)
  #   defp limit(%Ash.Page.Offset{limit: limit}), do: limit
  #   defp limit(_), do: 0

  #   defp count({:ok, %{count: count}}), do: count
  #   defp count(%{count: count}), do: count
  #   defp count(_), do: nil
  #   defp run_query() do
  #     fn filter, sort, fields, context ->
  #       page_params =
  #         case context.action.pagination do
  #           false ->
  #             false

  #           %{offset?: true} ->
  #             context[:page_params] || [offset: 0]

  #           _ ->
  #             context[:page_params]
  #         end

  #       context.resource
  #       |> Ash.Query.filter(^filter)
  #       |> Ash.Query.sort(sort)
  #       |> Ash.Query.load(fields)
  #       |> Ash.Query.set_tenant(context.tenant)
  #       |> context.api.read(
  #         page: page_params,
  #         action: context.action.name,
  #         actor: context.actor,
  #         authorize?: context.authorizing?
  #       )
  #     end
end
