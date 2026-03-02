import 'package:json_annotation/json_annotation.dart';

part 'credibility_score.g.dart';

enum RiskLevel {
    @JsonValue("low") low,
    @JsonValue("medium") medium,
    @JsonValue("high") high,
}

@JsonSerializable()
class CredibilityScore {
  final String id;
  final String organisationId;
  final double totalScore;
  final RiskLevel riskLevel;
  final List<String> topContributingFactors;
  final String? generalExplanation;
  final String modelVersion;
  final DateTime calculatedAt;

  CredibilityScore({
    required this.id,
    required this.organisationId,
    required this.totalScore,
    required this.riskLevel,
    required this.topContributingFactors,
    this.generalExplanation,
    required this.modelVersion,
    required this.calculatedAt,
  });

  factory CredibilityScore.fromJson(Map<String, dynamic> json) => _$CredibilityScoreFromJson(json);
  Map<String, dynamic> toJson() => _$CredibilityScoreToJson(this);

}
