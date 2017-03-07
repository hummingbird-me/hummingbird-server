class CommentLikePolicy < ApplicationPolicy
  include GroupPermissionsHelpers

  def update?
    false
  end

  def create?
    return false if user&.blocked?(record.comment.user)
    return false if user&.blocked?(record.comment.post.user)
    return false if group && !member?
    record.user == user
  end
  alias_method :destroy?, :create?

  def group
    record.comment.post.target_group
  end

  class Scope < Scope
    def resolve
      scope.where.not(user_id: blocked_users)
    end
  end
end
