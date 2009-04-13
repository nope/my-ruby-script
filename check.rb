#!/usr/bin/env ruby -wKU
# 
#  check.rb
#  studio
#  
#  Created by luca sabato on 2009-04-13.
#  Copyright 2009 http://sabatia.it. All rights reserved.
# 

require "net/http"
require "uri"

class Page
  #classe dei link, il flag status indica lo stato della scansione
  include Comparable

  attr_accessor :link, :status, :n
  def initialize(link, status = false, n = 0)
    @link = link #URI
    @status = status
    @n = n
  end
  
  def to_s
    return "#{@link.to_s}: #{@status} - #{@n}\n"
  end
    
  def <=>(other)
    self.n<=>other.n
  end

end

class Site
  #classe che raccoglie la lista di pagine
  #:host host delle homa page
  #:page array di Page contenete i link da esaminare
  attr_accessor :host, :page
  
  def initialize(home)
    @host = URI.parse(home).host
    @page = [Page.new(URI.parse(home))]
  end

  def scan
  #effettua lo scan della pagina passata e aggiunge i link in coda a page[]
    puts "Inizio esame: #{@page.length} link"
    @page.map do |cpage|
      puts "Esamino: #{cpage.link} - di #{@page.length} link"
      if !cpage.status
        #fai la scansione
        cpage.status = true

        #ottieni il body della pagina
        res = Net::HTTP.get_response(cpage.link)
        res.body.each_line do |line|
          #per ogni linea del body estrai i link
          #fixme non riconosce le immagini ed i feed
          if line =~/href="([http:\w\/\.\-_]+)\">?/
            #aggiorna il contatore
            cpage.n += 1
            temp_link = URI.parse($1)
            #crea una nuova pagina se l'host coincide e la pagina non esiste
            if (temp_link.host == @host)
              flag = false
              #fixme è una soluzione troppo lenta
              @page.each do |unico|
                  flag = true if (unico.link.to_s == temp_link.to_s) 
              end
              tpage = Page.new(temp_link)
              @page.push(tpage) unless flag
              #puts "pagina #{URI.parse($1)} aggiunta contente #{cpage.n} link."
            end
              
          end
        end

      end
    end
    puts "Esame terminato"
  end
  
  def stampa
    puts "\n\n\n Resoconto:\n"
    @page.sort!.reverse!
    @page.each do |line|
      puts line.to_s
    end
  end
end
  

miosito = Site.new("http://sabatia.it")
miosito.scan
miosito.stampa