# -*- coding: utf-8 -*-
class CartsController < ApplicationController

  before_filter :cart_id_discrepancy

  # GET /carts
  # GET /carts.xml
  def index
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

    respond_to do |format|
      format.html { redirect_to(carts_url) }
      format.xml  { head :ok }
    end
  end


  # URL にカートの id が含まれており、かつ session[:cart_id] が存在して
  # いない、または存在していても URL で指定のカートの id に一致しない場
  # 合は ストアのページにリダイレクトさせる
  def cart_id_discrepancy
    # 管理者としてログインしているとき (session[:user_id] が nil ではな
    # い) は、データベース上のカートの内容を自由に閲覧することができる
    return true unless session[:user_id].nil?

    if params[:id] && (params[:id].to_param.to_i != current_cart.id)
      redirect_to store_path,
      :notice => %{何を考えてんだよ !! (カート ID は #{current_cart.id} だけど、params は #{params[:id]} だよ)}
    end
  end

end
