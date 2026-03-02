// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'credibility_score.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CredibilityScore _$CredibilityScoreFromJson(Map<String, dynamic> json) =>
    CredibilityScore(
      id: json['id'] as String,
      organisationId: json['organisationId'] as String,
      totalScore: (json['totalScore'] as num).toDouble(),
      riskLevel: $enumDecode(_$RiskLevelEnumMap, json['riskLevel']),
      topContributingFactors: (json['topContributingFactors'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      generalExplanation: json['generalExplanation'] as String?,
      modelVersion: json['modelVersion'] as String,
      calculatedAt: DateTime.parse(json['calculatedAt'] as String),
    );

Map<String, dynamic> _$CredibilityScoreToJson(CredibilityScore instance) =>
    <String, dynamic>{
      'id': instance.id,
      'organisationId': instance.organisationId,
      'totalScore': instance.totalScore,
      'riskLevel': _$RiskLevelEnumMap[instance.riskLevel]!,
      'topContributingFactors': instance.topContributingFactors,
      'generalExplanation': instance.generalExplanation,
      'modelVersion': instance.modelVersion,
      'calculatedAt': instance.calculatedAt.toIso8601String(),
    };

const _$RiskLevelEnumMap = {
  RiskLevel.low: 'low',
  RiskLevel.medium: 'medium',
  RiskLevel.high: 'high',
};
