# -*- coding: utf-8 -*-
class CartsController < ApplicationController

  before_filter :cart_id_discrepancy

  # GET /carts
  # GET /carts.xml
  def index
    # 管理者でなければ、:show アクションにリダイレクトする
    if !admin?
      redirect_to cart_url(current_cart.id), :notice => 'Indexing carts not allowed'
      return
    end

    @carts = Cart.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @carts }
    end
  end

  # GET /carts/1
  # GET /carts/1.xml
  def show
    begin
      @cart = Cart.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      logger.error "Attempt to access invalid cart #{params[:id]}"
      redirect_to store_url, :notice => 'Invalid cart'
    else
      @line_items = @cart.line_items

      respond_to do |format|
        format.html # show.html.erb
        format.xml  { render :xml => @cart }
      end
    end
  end

  # GET /carts/new
  # GET /carts/new.xml
  def new
    @cart = Cart.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @cart }
    end
  end

  # GET /carts/1/edit
  def edit
    @cart = Cart.find(params[:id])
  end

  # POST /carts
  # POST /carts.xml
  def create
    @cart = Cart.new(params[:cart])

    respond_to do |format|
      if @cart.save
        format.html { redirect_to(@cart, :notice => 'Cart was successfully created.') }
        format.xml  { render :xml => @cart, :status => :created, :location => @cart }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @cart.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /carts/1
  # PUT /carts/1.xml
  def update
    @cart = Cart.find(params[:id])

    respond_to do |format|
      if @cart.update_attributes(params[:cart])
        format.html { redirect_to(@cart, :notice => 'Cart was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @cart.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /carts/1
  # DELETE /carts/1.xml
  def destroy
    @cart = Cart.find(params[:id])
    @cart.destroy
    session[:cart_id] = nil

    respond_to do |format|
      format.html { redirect_to(admin? ? carts_url : store_url,
                                :notice => admin? ? "Cart of id #{@cart.id} successfully deleted" : "Your cart is currently empty") }
      format.xml  { head :ok }
    end
  end


  # URL にカートの id が含まれており、かつ session[:cart_id] が存在して
  # いない、または存在していても URL で指定のカートの id に一致しない場
  # 合は ストアのページにリダイレクトさせる
  def cart_id_discrepancy
    # 管理者としてログインしているとき (ApplicationController#admin?
    # が true を返す) は、データベース上のカートの内容を自由に閲覧する
    # ことができる
    return true if admin?

    if params[:id] && (params[:id].to_param.to_i != current_cart.id)
      redirect_to store_url,
      :notice => "Operation denied because the cart of id #{params[:id]} is not yours"
    end
  end

end
