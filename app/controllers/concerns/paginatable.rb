module Paginatable
  extend ActiveSupport::Concern

  private

  def page
    params[:page]&.to_i || 1
  end

  def per_page
    per = params[:per_page]&.to_i || 10
    per > 100 ? 100 : per # Max 100 per page
  end

  def paginate(relation)
    relation.limit(per_page).offset((page - 1) * per_page)
  end

  def paginate_array(array)
    array.slice((page - 1) * per_page, per_page) || []
  end

  def pagination_meta(relation)
    total_count = relation.count
    {
      current_page: page,
      per_page: per_page,
      total_pages: (total_count / per_page.to_f).ceil,
      total_count: total_count
    }
  end

  def pagination_meta_for_array(array)
    total_count = array.length
    {
      current_page: page,
      per_page: per_page,
      total_pages: (total_count / per_page.to_f).ceil,
      total_count: total_count
    }
  end
end
