import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:mobile_dashboard/domain/models.dart';

class GitHubApi {
  Future<List<String>> fetchCommitsSha(
      String username, String repository, String token) async {
    final url =
        Uri.https('api.github.com', '/repos/$username/$repository/commits');
    final response = await http.get(
      url,
      headers: {
        'Accept': 'application/vnd.github+json',
        'Authorization': 'Bearer $token',
        'X-GitHub-Api-Version': '2022-11-28'
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map<String>((commit) => commit['sha']).toList();
    } else {
      throw Exception('Failed to fetch repository commits');
    }
  }

  Future<List<StringNumValue>> fetchModifiedFiles(
      String owner, String repo, String token) async {
    final commits = await fetchCommitsSha(owner, repo, token);
    final List<StringNumValue> modifiedFiles = [];

    for (final commit in commits) {
      final response = await http.get(
        Uri.https('api.github.com', '/repos/$owner/$repo/commits/$commit'),
        headers: {
          'Accept': 'application/vnd.github+json',
          'Authorization': 'Bearer $token',
          'X-GitHub-Api-Version': '2022-11-28'
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> commitData = jsonDecode(response.body);
        final changesUrl = commitData['commit']['tree']['url'];

        final changesResponse = await http.get(
          Uri.parse(changesUrl),
          headers: {
            'Accept': 'application/vnd.github+json',
            'Authorization': 'Bearer $token',
            'X-GitHub-Api-Version': '2022-11-28'
          },
        );

        if (changesResponse.statusCode == 200) {
          final Map<String, dynamic> changesData =
              jsonDecode(changesResponse.body);
          for (final change in changesData.entries) {
            print("!!! change: $change");
            // final String filename = change['path'];
            // final int additions = change['additions'];
            // final int deletions = change['deletions'];
            // final int modifications = additions + deletions;

            modifiedFiles.add(StringNumValue("", 1));
          }
        }
      }
    }

    return modifiedFiles;
  }
}