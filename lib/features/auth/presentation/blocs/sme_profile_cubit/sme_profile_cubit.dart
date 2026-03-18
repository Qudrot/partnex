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
    String? phoneNumber,
  }) {
    emit(state.copyWith(
      businessName: businessName,
      industry: industry,
      location: location,
      yearsOfOperation: yearsOfOperation,
      numberOfEmployees: numberOfEmployees,
      phoneNumber: phoneNumber,
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
      dataSource: DataSource.selfReported,
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
      dataSource: DataSource.selfReported,
    ));
  }

  void updateFromMap(Map<String, dynamic> map) {
    emit(SmeProfileState.fromMap(map));
  }

  void updateBio({
    required String bio,
    String? websiteUrl,
    String? whatsappNumber,
    String? linkedinUrl,
    String? twitterHandle,
  }) {
    emit(state.copyWith(
      bio: bio,
      websiteUrl: websiteUrl,
      whatsappNumber: whatsappNumber,
      linkedinUrl: linkedinUrl,
      twitterHandle: twitterHandle,
    ));
  }

  Future<void> processCsv(String csvString, String fileName) async {
    emit(state.copyWith(
      csvProcessingStatus: CsvProcessingStatus.processing,
      csvErrorMessage: null,
      documentFileName: fileName,
    ));

    try {
      final result = await compute(_parseCsvIsolate, csvString);

      // 1. Check for Hard Errors (e.g., < 24 months)
      if (result.containsKey('error')) {
        emit(state.copyWith(
          csvProcessingStatus: CsvProcessingStatus.error,
          csvErrorMessage: result['error'].toString(),
        ));
        return;
      }

      // 2. Check for Warnings
      if (result['warning'] != null) {
        if (kDebugMode) print("CSV WARNING: ${result['warning']}");
      }

      // 3. Extract the strictly calculated Rolling 12-Month blocks
      double a1 = result['year1Revenue'] as double;
      double a2 = result['year2Revenue'] as double;
      double a3 = result['year3Revenue'] as double;
      
      // We pass Year 1's exact trailing expenses divided by 12, so the dashboard calculator is perfectly synced!
      double y1Expenses = result['year1Expenses'] as double;
      double monthlyExp = y1Expenses / 12;

      int currentYear = DateTime.now().year;

      emit(state.copyWith(
        // We use currentYear just for UI labeling, the amounts are based strictly on rolling chronological periods
        annualRevenueYear1: currentYear,
        annualRevenueAmount1: a1,
        annualRevenueYear2: currentYear - 1,
        annualRevenueAmount2: a2,
        annualRevenueYear3: currentYear - 2,
        annualRevenueAmount3: a3,
        monthlyAvgExpenses: monthlyExp,
        totalLiabilities: (result['totalDebt'] as double),
        outstandingLoans: (result['totalDebt'] as double),
        priorFundingSource: "Extracted from CSV",
        csvProcessingStatus: CsvProcessingStatus.success,
        dataSource: DataSource.uploaded,
      ));
    } catch (e) {
      emit(state.copyWith(
        csvProcessingStatus: CsvProcessingStatus.error,
        csvErrorMessage: 'Failed to process CSV: ${e.toString()}',
      ));
    }
  }

  // --- BULLETPROOF PARSERS ---
  static double _sanitizeAmount(String rawValue) {
    if (rawValue.isEmpty) return 0.0;
    String cleanString = rawValue.replaceAll(',', '').replaceAll(' ', '').replaceAll('₦', '').replaceAll('N', '').trim();
    return (double.tryParse(cleanString) ?? 0.0).abs(); 
  }

  static DateTime? _parseDate(String dateStr) {
    DateTime? d = DateTime.tryParse(dateStr);
    if (d != null) return d;
    final match = RegExp(r'^(\d{1,2})[/-](\d{1,2})[/-](\d{4})').firstMatch(dateStr);
    if (match != null) return DateTime(int.parse(match.group(3)!), int.parse(match.group(2)!), int.parse(match.group(1)!));
    return null;
  }

  static Map<String, dynamic> _parseCsvIsolate(String csvString) {
    try {
      final rows = CsvCodec().decoder.convert(csvString);
      if (rows.isEmpty) return {'error': 'The uploaded file appears to be empty.'};

      int headerRowIndex = -1;
      int creditIdx = -1, debitIdx = -1, descIdx = -1, dateIdx = -1;

      for (int i = 0; i < rows.length; i++) {
        final rowStrs = rows[i].map((e) => e.toString().toLowerCase()).toList();
        if (rowStrs.any((s) => s.contains("credit") || s.contains("deposit")) ||
            rowStrs.any((s) => s.contains("debit") || s.contains("withdrawal"))) {
          headerRowIndex = i;
          for (int j = 0; j < rowStrs.length; j++) {
            if (rowStrs[j].contains("credit") || rowStrs[j].contains("deposit")) {
              creditIdx = j;
            } else if (rowStrs[j].contains("debit") || rowStrs[j].contains("withdrawal")) {
              debitIdx = j;
            } else if (rowStrs[j].contains("narration") || rowStrs[j].contains("desc")) {
              descIdx = j;
            } else if (rowStrs[j].contains("date") || rowStrs[j].contains("time")) {
              dateIdx = j;
            }
          }
          break;
        }
      }

      if (headerRowIndex == -1 || dateIdx == -1) {
        return {'error': 'Invalid format. Ensure the statement has a Date, Debit, and Credit column.'};
      }

      List<Map<String, dynamic>> parsedRows = [];
      for (int i = headerRowIndex + 1; i < rows.length; i++) {
        final row = rows[i];
        if (dateIdx >= row.length) continue;
        DateTime? rowDate = _parseDate(row[dateIdx].toString());
        if (rowDate != null) {
          parsedRows.add({
            'date': rowDate,
            'credit': creditIdx != -1 && creditIdx < row.length ? _sanitizeAmount(row[creditIdx].toString()) : 0.0,
            'debit': debitIdx != -1 && debitIdx < row.length ? _sanitizeAmount(row[debitIdx].toString()) : 0.0,
            'desc': descIdx != -1 && descIdx < row.length ? row[descIdx].toString().toLowerCase() : '',
          });
        }
      }

      if (parsedRows.isEmpty) return {'error': 'Could not extract valid dates from the statement.'};

      // Step 1: Sort descending (Newest transactions first)
      parsedRows.sort((a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));

      // Step 2: The Gatekeeper (Check for 24 unique months)
      Set<String> allUniqueMonths = {};
      for (var row in parsedRows) {
        DateTime d = row['date'];
        allUniqueMonths.add('${d.year}-${d.month}');
      }
      int totalMonthsFound = allUniqueMonths.length;
      if (totalMonthsFound < 24) {
        return {'error': 'We found records for $totalMonthsFound months. For accurate credit analysis, Partnex requires at least 24 months of history. Please upload a fuller statement.'};
      }

      // Step 3: Rolling 12-Month Windows Setup
      DateTime maxDate = parsedRows.first['date']; // Newest date
      DateTime y1Start = maxDate.subtract(const Duration(days: 365));
      DateTime y2Start = y1Start.subtract(const Duration(days: 365));
      DateTime y3Start = y2Start.subtract(const Duration(days: 365));

      double year1Revenue = 0.0, year2Revenue = 0.0, year3Revenue = 0.0;
      double year1Expenses = 0.0; // Strictly track Year 1 expenses for Profit Margin accuracy
      double totalDebt = 0.0;

      // Step 4: Sort data strictly into their time blocks based on exact Days, NOT calendar years
      for (var row in parsedRows) {
        DateTime d = row['date'];
        double credit = row['credit'];
        double debit = row['debit'];
        String desc = row['desc'];

        if (d.isAfter(y1Start) && !d.isAfter(maxDate)) {
          year1Revenue += credit;
          year1Expenses += debit;
        } else if (d.isAfter(y2Start) && !d.isAfter(y1Start)) {
          year2Revenue += credit;
        } else if (totalMonthsFound >= 36 && d.isAfter(y3Start) && !d.isAfter(y2Start)) {
          year3Revenue += credit;
        }

        // Keep a running total of active debt detected across the valid timeline
        if (d.isAfter(y2Start) && !d.isAfter(maxDate)) {
          if (desc.contains("loan") || desc.contains("repayment") || desc.contains("carbon") || desc.contains("fairmoney")) {
            totalDebt += debit;
          }
        }
      }

      String? warningMessage;
      if (totalMonthsFound > 24 && totalMonthsFound < 36) {
        warningMessage = 'Analyzing the latest 24 months of data.';
      } else if (totalMonthsFound > 36) {
        warningMessage = 'Analyzing the latest 36 months of data.';
      }
      
      return {
        'year1Revenue': year1Revenue,
        'year2Revenue': year2Revenue,
        'year3Revenue': year3Revenue,
        'year1Expenses': year1Expenses,
        'totalDebt': totalDebt,
        'warning': warningMessage,
      };
    } catch(e) {
      return {'error': 'An unexpected error occurred while analyzing the statement structure.'};
    }
  }
  
  void updateContactInfo({
    String? name,
    String? email,
    String? position,
  }) {
    emit(state.copyWith(
      email: email,
      contactPosition: position,
    ));
    // Note: businessName is usually the name field if identity is SME
  }

  void updateSharingPolicy(bool allow) {
    emit(state.copyWith(allowSharing: allow));
  }

  void reset() {
    emit(const SmeProfileState());
  }
}