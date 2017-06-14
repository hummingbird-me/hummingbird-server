class GroupMemberPolicy < ApplicationPolicy
  include GroupPermissionsHelpers

  def update?
    required_permission = record.pleb? ? :members : :leaders
    has_group_permission?(required_permission)
  end

  def create?
    return false unless is_owner?
    return false if banned_from_group?
    group.open? || group.restricted?
  end

  def destroy?
    required_permission = record.pleb? ? :members : :leaders
    is_owner? || has_group_permission?(required_permission)
  end

  class Scope < Scope
    def resolve
      filted_scope = see_nsfw? ? scope : scope.sfw
      filted_scope.blocking(blocked_users).visible_for(user)
    end
  end
end
