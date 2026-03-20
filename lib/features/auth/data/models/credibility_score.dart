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
  final double impactScore;

  CredibilityScore({
    required this.id,
    required this.organisationId,
    required this.totalScore,
    required this.riskLevel,
    required this.topContributingFactors,
    this.generalExplanation,
    required this.modelVersion,
    required this.calculatedAt,
    this.impactScore = 0.7,
  });

  factory CredibilityScore.fromJson(Map<String, dynamic> json) => _$CredibilityScoreFromJson(json);
  Map<String, dynamic> toJson() => _$CredibilityScoreToJson(this);

  CredibilityScore copyWith({
    String? id,
    String? organisationId,
    double? totalScore,
    RiskLevel? riskLevel,
    List<String>? topContributingFactors,
    String? generalExplanation,
    String? modelVersion,
    DateTime? calculatedAt,
    double? impactScore,
  }) {
    return CredibilityScore(
      id: id ?? this.id,
      organisationId: organisationId ?? this.organisationId,
      totalScore: totalScore ?? this.totalScore,
      riskLevel: riskLevel ?? this.riskLevel,
      topContributingFactors: topContributingFactors ?? this.topContributingFactors,
      generalExplanation: generalExplanation ?? this.generalExplanation,
      modelVersion: modelVersion ?? this.modelVersion,
      calculatedAt: calculatedAt ?? this.calculatedAt,
      impactScore: impactScore ?? this.impactScore,
    );
  }
}
