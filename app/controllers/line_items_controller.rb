# -*- coding: utf-8 -*-
class LineItemsController < ApplicationController

  # URL がネストされていれば、@nested を true にする
  before_filter :cart_id_discrepancy, :check_nested, :set_cart

  # GET /line_items
  # GET /line_items.xml
  def index

    if @nested
      @line_items = Cart.find(params[:cart_id]).line_items
    else
      @line_items = (admin? ? LineItem.all : current_cart.line_items)
    end

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @line_items }
    end
  end

  # GET /line_items/1
  # GET /line_items/1.xml
  def show
    @line_item = @cart.line_items.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @line_item }
    end
  end

  # GET /line_items/new
  # GET /line_items/new.xml
  def new
    @line_item = LineItem.new

    # 製品の指定がない場合、ストアの画面に転送する
    begin
      @line_item.product = Product.find(params[:product_id])
      @line_item.cart = @cart = current_cart
    rescue ActiveRecord::RecordNotFound
      notice = params[:product_id].nil? ? 'No product ID' : 'Invalid product ID'
      redirect_to store_url, :notice => notice
      return
    end

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @line_item }
    end
  end

  # GET /line_items/1/edit
  def edit
    @line_item = @cart.line_items.find(params[:id])
  end

  # POST /line_items
  # POST /line_items.xml
  def create
    @line_item = @cart.add_product(params[:product_id])

    respond_to do |format|
      if @line_item.save
        # format.html { redirect_to(@line_item.cart, :notice => 'Line item was successfully created.') }
        format.html { redirect_to(store_url) }
        format.xml  { render :xml => @line_item, :status => :created, :location => @line_item }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @line_item.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /line_items/1
  # PUT /line_items/1.xml
  def update
    @line_item = LineItem.find(params[:id], :conditions => ['cart_id = ?', current_cart.id])

    respond_to do |format|
      if @line_item.update_attributes(params[:line_item])
        format.html { redirect_to(@line_item.cart, :notice => 'Line item was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @line_item.errors, :status => :unprocessable_entity }
      end
    end
  end

#+        format.html do
#+          if @nested
#+            redirect_to(line_item_path(@line_item), :notice => 'Line item was successfully updated.')
#+          else
#+            redirect_to(cart_path(current_cart), :notice => 'Line item was successfully updated.')
#+          end
#+        end
#         format.xml  { head :ok }
#       else
#-        format.html { render :action => "edit" }
#+        format.html do
#+          if @nested
#+            render :action => "edit" #, :cart_id => @line_item.cart
#+          else
#+            render :action => "edit"
#+          end
#+        end
#

  # DELETE /line_items/1
  # DELETE /line_items/1.xml
  def destroy
    @cart = current_cart
    @line_item = @cart.line_items.find(params[:id])
    @line_item.destroy

    respond_to do |format|
      format.html { redirect_to(cart_url(@cart)) }
      format.xml  { head :ok }
    end
  end

  private

  def check_nested
    @nested = params[:cart_id].nil? ? false : true
  end


  # URL にカートの id が含まれており、かつ session[:cart_id] が存在して
  # いない、または存在していても URL で指定のカートの id に一致しない場
  # 合は ストアのページにリダイレクトさせる
  def cart_id_discrepancy
    # 管理者としてログインしているとき (ApplicationController#admin?
    # が true を返す) は、データベース上のカートの内容を自由に閲覧する
    # ことができる
    return true if admin?

    if params[:cart_id] && (params[:cart_id].to_param.to_i != current_cart.id)
      redirect_to store_url,
      :notice => %{何を考えてんだよ !! (カート ID は #{current_cart.id} だけど、params は #{params[:cart_id]} だよ)}
    end
  end

end
