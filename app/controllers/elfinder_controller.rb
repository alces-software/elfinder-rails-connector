#==============================================================================
# Copyright (C) 2007-2011 Stephen F Norledge & Alces Software Ltd.
#
# This file is part of elfinder-rails.
#
# elfinder-rails is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This software is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#                                                                               
# You should have received a copy of the GNU Affero General Public License
# along with this software.  If not, see <http://www.gnu.org/licenses/>.
#
# Some rights reserved, see LICENSE.txt.
#==============================================================================

load 'lib/elfinder.rb'

class ElfinderController < ::ActionController::Base
  class << self
    def volumes
      @volumes ||= [
        Elfinder::Volume::Directory.new('l1','Home','/tmp/scratch'),
        Elfinder::Volume::Directory.new('l2','Scratch 2','/tmp/scratch2'),
        Elfinder::Volume::Directory.new('h','markt Home','/Users/markt'),
#        Elfinder::Volume::Directory.new('l2','Documents','/Users/markt/Documents')
      ]
    end
  end

  delegate :volumes, :to => self

  def api
    cmd = params[:cmd]
    data = if cmd.present? && respond_to?(cmd,true)
             send(cmd)
           else
             {:error => "Unsupported operation: #{cmd}"}
           end
    case data
    when Hash
      render :json => data
    when String
      render :text => data
    else
      render :json => {:error => "Unsupported data type: #{data.class.name}"}
    end
  end

  private

  def open
    {
      :cwd => volume.cwd(path),
      :options => options
    }.tap do |data|
      if init?
        files = volumes.map { |vol| vol.files('/') }.flatten
        files += ( path == '/' ? [] : (volume.files(path) + volume.parents(path)) )
        data.merge!({
                      :api => '2.0',
                      :uplMaxSize => 0
                    })
      else
        files = volume.files(path)
      end
      data.merge!(:files => files)
    end
  end

  def tree
    { :tree => volume.tree(path) }
  end

  # find directory siblings and all parent directories up to the root
  def parents
    { :tree => volume.parents(path) }
  end

  def mkdir
    result = volume.mkdir(path,params[:name])
    if result == true
      { :added => volume.tree(File.join(path,params[:name])) }
    else
      { :error => result }
    end
  end

  def mkfile
    result = volume.mkfile(path,params[:name])
    if result == true
      { :added => [volume.file(path,params[:name])] }
    else
      { :error => result }
    end
  end

  def rm
    # accepts a targets[] array
    errors = []
    results = params[:targets].map do |target|
      v, p = Elfinder::Routing::route(target)
      v = volumes.find{|vol| vol.id == v}
      result = v.rm(p)
      STDERR.puts "THE RESULT IS: #{result}"
      if result == true
        v.hash_for(p)
      else
        errors << "\n#{result}"
        nil
      end
    end.compact
    {}.tap do |data|
      data[:removed] = results if results.any?
      data[:error] = errors.join('<br />') if errors.any?
    end
  end

  def rename
    result = volume.rename(path,params[:name])
    if result == true
      { 
        :added => [volume.file(volume.dirname(path),params[:name])],
        :removed => [volume.hash_for(path)]
      }
    else
      { :error => result }
    end
  end

  def duplicate
    # accepts a targets[] array
    errors = []
    results = params[:targets].map do |target|
      v, p = Elfinder::Routing::route(target)
      v = volumes.find{|vol| vol.id == v}
      result = v.duplicate(p)
      if result == true
        v.file(v.dirname(p),v.duplicate_name_for(p))
      else
        errors << "#{result}"
        nil
      end
    end.compact
    {}.tap do |data|
      data[:added] = results if results.any?
      data[:error] = errors.join('<br />') if errors.any?
    end    
  end
  
  def paste
    if params[:cut] == '1'
      cut
    else
      copy
    end
  end

  def copy
    # accepts a targets[] array
    errors = []
    added = []
    params[:targets].each do |target|
      src_v, src_p = Elfinder::Routing::route(target)
      src_v = volumes.find{|vol| vol.id == src_v}

      dest_v, dest_p = Elfinder::Routing::route(params[:dst])
      STDERR.puts "dest_v is: #{dest_v.inspect}"
      dest_v = volumes.find{|vol| vol.id == dest_v}
      STDERR.puts "dest_v is: #{dest_v.inspect}"

      result = src_v.copy(src_p,dest_v,dest_p)
      if result == true
        added << dest_v.file(dest_p,dest_v.name_for(src_p))
      else
        errors << "#{result}"
        nil
      end
    end.compact
    {}.tap do |data|
      data[:added] = added if added.any?
      data[:error] = errors.join('<br />') if errors.any?
    end    
  end

  def cut
    # accepts a targets[] array
    errors = []
    added = []
    removed = []
    params[:targets].each do |target|
      src_v, src_p = Elfinder::Routing::route(target)
      src_v = volumes.find{|vol| vol.id == src_v}

      dest_v, dest_p = Elfinder::Routing::route(params[:dst])
      dest_v = volumes.find{|vol| vol.id == dest_v}

      result = src_v.move(src_p,dest_v,dest_p)
      if result == true
        added << dest_v.file(dest_p,dest_v.name_for(src_p))
        removed << src_v.hash_for(src_p)
      else
        errors << "#{result}"
        nil
      end
    end.compact
    {}.tap do |data|
      data[:added] = added if added.any?
      data[:removed] = removed if removed.any?
      data[:error] = errors.join('<br />') if errors.any?
    end    
  end

  def file
    ## download a remote file
    filename = volume.name_for(path)
    mimetype = volume.mimetype(path)
    disp = if params[:download] == '0' && mimetype =~ /^image|text\//i || mimetype == 'application/x-shockwave-flash'
             # if this is an image or text or (fsr) flash file, we allow display inline
             "inline"
           else
             "attachment" 
           end
    if request.env['HTTP_USER_AGENT'] =~ /msie/i
      headers['Pragma'] = 'public'
      headers["Content-type"] = mimetype
      headers['Cache-Control'] = 'no-cache, must-revalidate, post-check=0, pre-check=0'
      headers['Content-Disposition'] = "#{disp}; filename=\"#{filename}\"" 
      headers['Expires'] = "0" 
    else
      headers["Content-Type"] ||= mimetype
      headers["Content-Disposition"] = "#{disp}; filename=\"#{filename}\"" 
    end
    volume.read(path)
  end
  
  def get
    ## get contents of a file
    {:content => volume.read(path)}
  end

  def put
    ## write contents to a file
    result = volume.write(path,params[:content])
    if result == true
      { :changed => [volume.file(path)] }
    else
      { :error => result }
    end
  end

  def ls
    { :list => volume.ls(path) }
  end

  # def tmb
  # end
  # def size
  # end
  # def upload
  # end
  # def archive
  # end
  # def extract
  # end
  # def search
  # end
  # def info
  # end
  # def dim
  # end
  # def resize
  # end

  private

  def volume
    @volume ||= begin
                  vol_id = decoded_volume_and_path.first
                  volumes.find{|vol| vol.id == vol_id}
                end
  end

  def path
    @path ||= begin 
                p = decoded_volume_and_path.last
                # Prevent requests for '.' and '..' breaking elfinder client
                raise "Invalid target path: '#{p}'" if p =~ /\.$/
                p.blank? ? '/' : p
              end
  end

  def decoded_volume_and_path
    @decoded_volume_and_path ||= if params[:target].present?
                                   Elfinder::Routing::route(params[:target])
                                 else
                                   [volumes.first.id,'/']
                                 end
  end


  def options
    {
      archivers: {},
      # copyOverwrite enables a prompt before overwriting files
      copyOverwrite: 1,
      disabled: [],
      path: 'Home/',
      separator: '/',
      tmbUrl: 'http://foobar/thumbs/',
      url: 'http://foobar/'
    }
  end

  def init?
    params[:init] && params[:init] == '1'
  end

  def tree?
    params[:tree] && params[:tree] == '1'
  end

end

