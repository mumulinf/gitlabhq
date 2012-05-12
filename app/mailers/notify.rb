class Notify < ActionMailer::Base
  include Resque::Mailer
  add_template_helper ApplicationHelper

  default_url_options[:host] = EMAIL_OPTS["host"]
  default_url_options[:protocol] = -> { EMAIL_OPTS["protocol"] ? EMAIL_OPTS["protocol"] : "http" }.call

  default from: EMAIL_OPTS["from"]

  def new_user_email(user, password)
    @user = user
    @password = password
    mail(:to => @user['email'], :subject => "gitlab | Account was created for you")
  end

  def new_issue_email(issue)
    @issue = Issue.find(issue['id'])
    @user = @issue.assignee
    @project = @issue.project

    mail(:to => @user.email, :subject => "gitlab | New Issue was created")
  end

  def note_wall_email(user, note)
    @user = user
    @note = Note.find(note['id'])
    @project = @note.project
    mail(:to => @user['email'], :subject => "gitlab | #{@note.project.name} ")
  end

  def note_commit_email(user, note)
    @user = user
    @note = Note.find(note['id'])
    @project = @note.project
    @commit = @note.target
    mail(:to => @user['email'], :subject => "gitlab | note for commit | #{@note.project.name} ")
  end
  
  def note_merge_request_email(user, note)
    @user = user
    @note = Note.find(note['id'])
    @project = @note.project
    @merge_request = @note.noteable
    mail(:to => @user['email'], :subject => "gitlab | note for merge request | #{@note.project.name} ")
  end

  def note_issue_email(user, note)
    @user = user
    @note = Note.find(note['id'])
    @project = @note.project
    @issue = @note.noteable
    mail(:to => @user['email'], :subject => "gitlab | note for issue #{@issue.id} | #{@note.project.name} ")
  end
  
  def new_merge_request_email(merge_request)
    @merge_request = MergeRequest.find(merge_request['id'])
    @user = @merge_request.assignee
    @project = @merge_request.project
    mail(:to => @user.email, :subject => "gitlab | new merge request | #{@merge_request.title} ")
  end
  
  def changed_merge_request_email(user, merge_request)
    @user = user
    @merge_request = MergeRequest(merge_request.id)
    @assignee_was ||= User.find(@merge_request.assignee_id_was)
    @project = @merge_request.project
    mail(:to => @user['email'], :subject => "gitlab | merge request changed | #{@merge_request.title} ")
  end
  
  def changed_issue_email(user, issue)
    @issue = Issue.find(issue['id'])
    @user = user
    @assignee_was ||= User.find(@issue.assignee_id_was)
    @project = @issue.project
    mail(:to => @user['email'], :subject => "gitlab | changed issue | #{@issue.title} ")
  end
end
