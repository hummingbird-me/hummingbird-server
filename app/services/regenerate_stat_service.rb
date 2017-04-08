class RegenerateStatService
  class << self
    def anime_genre_breakdown
      User.where(id: LibraryEntry.select(:user_id).by_kind(:anime))
          .find_each do |user|
            user.stats.find_by(type: 'Stat::AnimeGenreBreakdown').recalculate!
          end
    end

    def anime_amount_watched
      User.where(id: LibraryEntry.select(:user_id).by_kind(:anime))
          .find_each do |user|
            user.stats.find_by(type: 'Stat::AnimeAmountWatched').recalculate!
          end
    end
  end
end
