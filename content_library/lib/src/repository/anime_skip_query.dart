// ignore_for_file: constant_identifier_names

class AnimeSkipQuery {
  AnimeSkipQuery._();

  static const String TIMESTAMPSBYNAME = """
          query Data(\$search: String!,\$offset: Int!,\$limit: Int!, \$sort: String!)  {        
    searchShows(search: \$search, offset: \$offset, limit: \$limit, sort: \$sort) {
            id
            name
            image
            episodes {
              name
              id
              createdAt
              updatedAt
              season
              number
              absoluteNumber
              baseDuration
              timestamps {
                id
                createdAt
                updatedAt
                episode {
                  name,
                  number,
                  absoluteNumber,
                }
                at
                type{
                  createdBy {
                    username
                  }
                  updatedBy{
                    username
                  }
                  name
                }
              }
            }
          }
        }
  """;
}
