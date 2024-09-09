import 'dart:convert';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:kajecik/components/api_response.dart';


class ApiService {
  final String apiKey = '*******';

  Future<List<ApiResponse>> fetchSearch(String query) async {
    final response = await http.get(Uri.parse(
        'https://api.watchmode.com/v1/autocomplete-search/?apiKey=$apiKey&search_value=$query&search_type=1'));
    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body)['results'];
      return jsonResponse.map((series) => ApiResponse.fromJson(series)).toList();
    } else {
      throw Exception('Failed to load tv series');
    }
  }

  Future<Map<String,dynamic>> fetchDetails(String? query) async {
    if (query!.isEmpty) {
      throw Exception('nie udało się id puste');
    }
    final response = await http.get(Uri.parse(
        'https://api.watchmode.com/v1/title/$query/details/?apiKey=$apiKey'));

    if (response.statusCode == 200) {
      Map<String,dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse;
    } else {
      throw Exception('Failed to load tv series');
    }
  }

Future<Map<String,dynamic>> fetchImdbApi(String imdbId, GraphQLClient client) async {
    //final client = GraphQLProvider.of(context)
    // final client = GraphQLProvider.of(context).value;
    final QueryOptions options = QueryOptions( //"tt14417144"
      document: gql(r'''
        query titleById($id: ID!) {
          title(id: $id) {
            id
            type
            is_adult
            primary_title
            original_title
            start_year
            end_year
            plot
            rating {
              aggregate_rating
              votes_count
            }
            genres
            posters {
              url
            }
            critic_review {
              score
              review_count
            }
          }
        }
      '''),
      variables: {'id': imdbId},
    );

    final QueryResult result = await client.query(options);

    if (result.hasException) {
      //print('Error fetching users: ${result.exception.toString()}');
      throw Exception('Failed to load tv series');
    }

    Map<String, dynamic> jsonResponse = result.data!['title'];
    //print(jsonResponse);
    return jsonResponse;
    
  }
}



