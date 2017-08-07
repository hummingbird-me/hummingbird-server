class GroupPolicy < ApplicationPolicy
  include GroupPermissionsHelpers

  def create?
    user ? true : false
  end

  def update?
    has_group_permission? :community
  end

  def destroy?
    has_group_permission? :owner
  end

  def editable_attributes(all)
    return all if is_admin?

    all - %i[members_count leaders_count neighbors_count rules_formatted
             featured name pinned_post_id]
  end

  def creatable_attributes(all)
    return all if is_admin?

    all - %i[members_count leaders_count neighbors_count rules_formatted
             featured pinned_post_id]
  end

  def group
    record
  end

  class Scope < Scope
    def resolve
      return scope.visible_for(user) if see_nsfw?
      scope.sfw.visible_for(user)
    end
  end
end
