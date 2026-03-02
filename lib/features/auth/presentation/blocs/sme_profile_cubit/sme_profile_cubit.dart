import 'package:flutter/foundation.dart';
import 'package:csv/csv.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'sme_profile_state.dart';

class SmeProfileCubit extends Cubit<SmeProfileState> {
  SmeProfileCubit() : super(const SmeProfileState());

  void updateBusinessProfile({
    required String businessName,
    required String industry,
    required String location,
    required int yearsOfOperation,
    required int numberOfEmployees,
  }) {
    emit(state.copyWith(
      businessName: businessName,
      industry: industry,
      location: location,
      yearsOfOperation: yearsOfOperation,
      numberOfEmployees: numberOfEmployees,
    ));
  }

  void updateRevenueExpenses({
    required int annualRevenueYear1,
    required double annualRevenueAmount1,
    required int annualRevenueYear2,
    required double annualRevenueAmount2,
    int? annualRevenueYear3,
    double? annualRevenueAmount3,
    double? monthlyAvgRevenue,
    required double monthlyAvgExpenses,
    String? documentFileName,
  }) {
    emit(state.copyWith(
      annualRevenueYear1: annualRevenueYear1,
      annualRevenueAmount1: annualRevenueAmount1,
      annualRevenueYear2: annualRevenueYear2,
      annualRevenueAmount2: annualRevenueAmount2,
      annualRevenueYear3: annualRevenueYear3,
      annualRevenueAmount3: annualRevenueAmount3,
      monthlyAvgRevenue: monthlyAvgRevenue,
      monthlyAvgExpenses: monthlyAvgExpenses,
      documentFileName: documentFileName,
    ));
  }

  void updateLiabilitiesHistory({
    required double totalLiabilities,
    required double outstandingLoans,
    bool? hasPriorFunding,
    double? priorFundingAmount,
    String? priorFundingSource,
    int? fundingYear,
    String? repaymentHistory,
  }) {
    emit(state.copyWith(
      totalLiabilities: totalLiabilities,
      outstandingLoans: outstandingLoans,
      hasPriorFunding: hasPriorFunding,
      priorFundingAmount: priorFundingAmount,
      priorFundingSource: priorFundingSource,
      fundingYear: fundingYear,
      repaymentHistory: repaymentHistory,
    ));
  }

  /// Entry point for UI to trigger background CSV processing
  Future<void> processCsv(String csvString, String fileName) async {
    emit(state.copyWith(
      csvProcessingStatus: CsvProcessingStatus.processing,
      csvErrorMessage: null,
      documentFileName: fileName,
    ));

    try {
      // Offload extraction to a separate Isolate
      final result = await compute(_parseCsvIsolate, csvString);

      if (result.containsKey('error')) {
        emit(state.copyWith(
          csvProcessingStatus: CsvProcessingStatus.error,
          csvErrorMessage: result['error'].toString(),
        ));
        return;
      }

      // Update state with extracted data
      emit(state.copyWith(
        annualRevenueYear1: DateTime.now().year - 1,
        annualRevenueAmount1: (result['totalRevenue'] as double),
        annualRevenueYear2: DateTime.now().year - 2,
        annualRevenueAmount2: (result['totalRevenue'] as double) * 0.8,
        monthlyAvgExpenses: (result['totalExpenses'] as double) / 12,
        totalLiabilities: (result['totalDebt'] as double),
        outstandingLoans: (result['totalDebt'] as double),
        priorFundingSource: "Extracted from CSV",
        onTimePayments: 12, // Default healthy baseline for bank-verified data
        latePayments: 0,
        numDocumentsSubmitted: 1, // The CSV itself
        areDocumentsRecent: true,
        areDocumentsComplete: true,
        areDocumentsConsistent: true,
        csvProcessingStatus: CsvProcessingStatus.success,
      ));
    } catch (e) {
      emit(state.copyWith(
        csvProcessingStatus: CsvProcessingStatus.error,
        csvErrorMessage: e.toString(),
      ));
    }
  }

  /// Pure function that runs in a background Isolate
  static Map<String, dynamic> _parseCsvIsolate(String csvString) {
    try {
      final rows = CsvCodec().decoder.convert(csvString);
      if (rows.isEmpty) return {'error': 'The CSV file is empty.'};

      final headers = rows.first.map((e) => e.toString().toLowerCase()).toList();
      
      int creditIdx = -1;
      int debitIdx = -1;
      int descIdx = -1;

      for (int i = 0; i < headers.length; i++) {
        if (headers[i].contains("credit") || headers[i].contains("deposit")) {
          creditIdx = i;
        } else if (headers[i].contains("debit") || headers[i].contains("withdrawal")) {
          debitIdx = i;
        } else if (headers[i].contains("narration") || headers[i].contains("description") || headers[i].contains("details")) {
          descIdx = i;
        }
      }

      double totalRevenue = 0.0;
      double totalExpenses = 0.0;
      double totalDebt = 0.0;

      for (int i = 1; i < rows.length; i++) {
        final row = rows[i];
        
        if (creditIdx != -1 && creditIdx < row.length) {
          final val = double.tryParse(row[creditIdx].toString().replaceAll(RegExp(r'[^0-9.]'), ''));
          if (val != null) totalRevenue += val;
        }

        if (debitIdx != -1 && debitIdx < row.length) {
          final val = double.tryParse(row[debitIdx].toString().replaceAll(RegExp(r'[^0-9.]'), ''));
          if (val != null) totalExpenses += val;
        }

        if (descIdx != -1 && descIdx < row.length && debitIdx != -1 && debitIdx < row.length) {
          final desc = row[descIdx].toString().toLowerCase();
          if (desc.contains("loan") || desc.contains("fairmoney") || desc.contains("branch") || desc.contains("carbon")) {
            final debtVal = double.tryParse(row[debitIdx].toString().replaceAll(RegExp(r'[^0-9.]'), ''));
            if (debtVal != null) totalDebt += debtVal;
          }
        }
      }

      return {
        'totalRevenue': totalRevenue,
        'totalExpenses': totalExpenses,
        'totalDebt': totalDebt,
      };
    } catch (e) {
      return {'error': e.toString()};
    }
  }
  
  void reset() {
    emit(const SmeProfileState());
  }
}
