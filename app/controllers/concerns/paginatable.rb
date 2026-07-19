module Paginatable
  extend ActiveSupport::Concern

  private

  def pagination_meta(paginated_collection)
    {
      current_page: paginated_collection.current_page,
      per_page: paginated_collection.limit_value,
      total_pages: paginated_collection.total_pages,
      total_count: paginated_collection.total_count
    }
  end
end
