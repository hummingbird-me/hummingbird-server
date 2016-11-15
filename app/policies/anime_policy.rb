class AnimePolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user && !user.sfw_filter?
        scope
      else
        scope.sfw
      end
    end
  end
end
