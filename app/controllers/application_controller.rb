class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  protect_from_forgery
  private
  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end
  helper_method :current_user
  def checkLogin
    unless current_user
	  alertmesg("請先登入, 謝謝!")
	  redirect_to root_url
	  return false
	end
	return true
  end
  def checkTopManager
    
    if checkLogin
	  @topmanager=TopManager.find_by_user_id(current_user.id)
	  case params[:controller]
		when 'user'
		  unless @topmanager && @topmanager.all_users==1
		  alertmesg("您沒有操作此動作的權限")     
		  redirect_to root_url
		  end
		when 'departments'
		  unless @topmanager && @topmanager.all_departments==1
		  alertmesg("您沒有操作此動作的權限")     
		  redirect_to root_url
		  end
	  end
      
    end    
  end
  
  def checkCourseManager #(course_id)
    
    if checkLogin
	  @departments=CourseManager.where(:user_id=>current_user.id)
	  if @departments
	    @departments.each do |department|
		  
		  department.courses.each do |course|
		    return true if course.id==params[:id]#course_id
		  end
		end
	  #else
		
	  end
	  alertmesg("您沒有操作此動作的權限")     
		  redirect_to root_url
    end
    
  end
  
  def checkOwner
    case params[:controller] 
      when 'post'
		if Post.find(params[:id]).owner_id!=current_user.id
		  alertmesg("您沒有操作此動作的權限")     
		  redirect_to root_url
		#else return true
		end
	  when 'files'
	    @file=FileInfo.find_by_id(params[:id])
	    if @file && @file.owner_id!=current_user.id
		  alertmesg("您沒有操作此動作的權限")
		  redirect_to root_url
		#else return true
		end	  
    end
  end
  
  
  def alertmesg(msg)
    flash[:notice] = {
			:style => "alert-info",
			:title => "Sorry!",
			:message => msg
		  }
  end  
end