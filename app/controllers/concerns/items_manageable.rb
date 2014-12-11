module ItemsManageable

  def find_or_create_item
    @item = @project.items.where(sku: params[:item][:sku]).first_or_create(item_params)
  end

  private

    def item_params
      params.require(:item).permit(:sku, :name)
    end
end
