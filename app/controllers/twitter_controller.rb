class TwitterController < ApplicationController
  
  def index
    limit = 100
    
    if params[:limit].present? && params[:limit].to_i > 0 && params[:limit].to_i < 100
      limit = params[:limit].to_i
    end
    
    logger.info limit
    
    @tweets = Tweet.limit(limit)
    
    if params[:after].present?
      @tweets.where(:_id.gt => BSON::ObjectId.from_string(params[:after]))
    end
    
    respond_to do |format|
      format.json{render :json => @tweets}
    end
  end
  
end
