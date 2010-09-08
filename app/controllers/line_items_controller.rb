# -*- coding: utf-8 -*-
class LineItemsController < ApplicationController

  # URL がネストされていれば、@nested を true にする
  before_filter :check_nested

  # GET /line_items
  # GET /line_items.xml
  def index
    @line_items = current_cart.line_items

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @line_items }
    end
  end

  # GET /line_items/1
  # GET /line_items/1.xml
  def show
    @cart = current_cart
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
    @cart = current_cart
    @line_item = @cart.line_items.find(params[:id])
  end

  # POST /line_items
  # POST /line_items.xml
  def create
    @cart = current_cart
    @line_item = @cart.add_product(params[:product_id])

    respond_to do |format|
      if @line_item.save
        format.html { redirect_to(@line_item.cart, :notice => 'Line item was successfully created.') }
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
end
