require 'rho'
require 'rho/rhocontroller'
require 'rho/rhoerror'
require 'helpers/browser_helper'

class HomeController < Rho::RhoController
  include BrowserHelper

  @scanner = nil

  def index
    render
  end

  def barcodes
    barcodes = []
    Rho::Barcode.enumerate.each_with_index do |scanner, index|
      barcodes << {:scannerType => scanner.scannerType, :friendlyName => scanner.friendlyName, :index => index}
    end
    barcodes
  end

  def scan
    if @scanner != nil
      @scanner.disable
    end
    index = @params['index'].to_i
    @scanner = Rho::Barcode.enumerate[index]
    if @scanner.scannerType == 'Camera'
      @scanner.take({}, url_for(:action => :scanner_callback))
    else
      @scanner.enable({}, url_for(:action => :scanner_callback))
    end
    render string: ::JSON.generate({})
  end

  def scanner_callback
    value = @params.has_key?('barcode') ? @params['barcode'] : @params['data']
    Rho::Notification.showStatus('Barcode Scanner', value, 'Close')
  end

end
