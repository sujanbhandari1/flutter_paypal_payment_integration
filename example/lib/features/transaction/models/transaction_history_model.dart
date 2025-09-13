class TransactionHistoryResponse {
  final List<TransactionDetail> transactionDetails;
  final String accountNumber;
  final String startDate;
  final String endDate;
  final String lastRefreshedDatetime;
  final int page;
  final int totalItems;
  final int totalPages;
  final List<ApiLink> links;

  TransactionHistoryResponse({
    required this.transactionDetails,
    required this.accountNumber,
    required this.startDate,
    required this.endDate,
    required this.lastRefreshedDatetime,
    required this.page,
    required this.totalItems,
    required this.totalPages,
    required this.links,
  });

  factory TransactionHistoryResponse.fromJson(Map<String, dynamic> json) {
    return TransactionHistoryResponse(
      transactionDetails: (json['transaction_details'] as List<dynamic>)
          .map((e) => TransactionDetail.fromJson(e))
          .toList(),
      accountNumber: json['account_number'],
      startDate: json['start_date'],
      endDate: json['end_date'],
      lastRefreshedDatetime: json['last_refreshed_datetime'],
      page: json['page'],
      totalItems: json['total_items'],
      totalPages: json['total_pages'],
      links: (json['links'] as List<dynamic>)
          .map((e) => ApiLink.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transaction_details': transactionDetails.map((e) => e.toJson()).toList(),
      'account_number': accountNumber,
      'start_date': startDate,
      'end_date': endDate,
      'last_refreshed_datetime': lastRefreshedDatetime,
      'page': page,
      'total_items': totalItems,
      'total_pages': totalPages,
      'links': links.map((e) => e.toJson()).toList(),
    };
  }
}

class TransactionDetail {
  final TransactionInfo transactionInfo;
  final PayerInfo? payerInfo;
  final ShippingInfo? shippingInfo;
  final CartInfo? cartInfo;

  TransactionDetail({
    required this.transactionInfo,
    this.payerInfo,
    this.shippingInfo,
    this.cartInfo,
  });

  factory TransactionDetail.fromJson(Map<String, dynamic> json) {
    return TransactionDetail(
      transactionInfo: TransactionInfo.fromJson(json['transaction_info']),
      payerInfo: json['payer_info'] != null
          ? PayerInfo.fromJson(json['payer_info'])
          : null,
      shippingInfo: json['shipping_info'] != null
          ? ShippingInfo.fromJson(json['shipping_info'])
          : null,
      cartInfo: json['cart_info'] != null
          ? CartInfo.fromJson(json['cart_info'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transaction_info': transactionInfo.toJson(),
      'payer_info': payerInfo?.toJson(),
      'shipping_info': shippingInfo?.toJson(),
      'cart_info': cartInfo?.toJson(),
    };
  }
}

class TransactionInfo {
  final String transactionId;
  final String transactionEventCode;
  final String transactionInitiationDate;
  final String transactionUpdatedDate;
  final Amount transactionAmount;
  final String transactionStatus;
  final String? transactionSubject;
  final Amount? endingBalance;
  final Amount? availableBalance;
  final Amount? feeAmount;

  TransactionInfo({
    required this.transactionId,
    required this.transactionEventCode,
    required this.transactionInitiationDate,
    required this.transactionUpdatedDate,
    required this.transactionAmount,
    required this.transactionStatus,
    this.transactionSubject,
    this.endingBalance,
    this.availableBalance,
    this.feeAmount,
  });

  factory TransactionInfo.fromJson(Map<String, dynamic> json) {
    return TransactionInfo(
      transactionId: json['transaction_id'],
      transactionEventCode: json['transaction_event_code'],
      transactionInitiationDate: json['transaction_initiation_date'],
      transactionUpdatedDate: json['transaction_updated_date'],
      transactionAmount: Amount.fromJson(json['transaction_amount']),
      transactionStatus: json['transaction_status'],
      transactionSubject: json['transaction_subject'],
      endingBalance: json['ending_balance'] != null
          ? Amount.fromJson(json['ending_balance'])
          : null,
      availableBalance: json['available_balance'] != null
          ? Amount.fromJson(json['available_balance'])
          : null,
      feeAmount: json['fee_amount'] != null
          ? Amount.fromJson(json['fee_amount'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transaction_id': transactionId,
      'transaction_event_code': transactionEventCode,
      'transaction_initiation_date': transactionInitiationDate,
      'transaction_updated_date': transactionUpdatedDate,
      'transaction_amount': transactionAmount.toJson(),
      'transaction_status': transactionStatus,
      'transaction_subject': transactionSubject,
      'ending_balance': endingBalance?.toJson(),
      'available_balance': availableBalance?.toJson(),
      'fee_amount': feeAmount?.toJson(),
    };
  }
}

class Amount {
  final String currencyCode;
  final String value;

  Amount({required this.currencyCode, required this.value});

  factory Amount.fromJson(Map<String, dynamic> json) {
    return Amount(currencyCode: json['currency_code'], value: json['value']);
  }

  Map<String, dynamic> toJson() {
    return {'currency_code': currencyCode, 'value': value};
  }
}

class PayerInfo {
  final String? emailAddress;
  final String? accountId;
  final String? payerStatus;
  final String? countryCode;
  final PayerName? payerName;

  PayerInfo({
    this.emailAddress,
    this.accountId,
    this.payerStatus,
    this.countryCode,
    this.payerName,
  });

  factory PayerInfo.fromJson(Map<String, dynamic> json) {
    return PayerInfo(
      emailAddress: json['email_address'],
      accountId: json['account_id'],
      payerStatus: json['payer_status'],
      countryCode: json['country_code'],
      payerName: json['payer_name'] != null
          ? PayerName.fromJson(json['payer_name'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email_address': emailAddress,
      'account_id': accountId,
      'payer_status': payerStatus,
      'country_code': countryCode,
      'payer_name': payerName?.toJson(),
    };
  }
}

class PayerName {
  final String? givenName;
  final String? surname;

  PayerName({this.givenName, this.surname});

  factory PayerName.fromJson(Map<String, dynamic> json) {
    return PayerName(givenName: json['given_name'], surname: json['surname']);
  }

  Map<String, dynamic> toJson() {
    return {'given_name': givenName, 'surname': surname};
  }
}

class ShippingInfo {
  final String? name;

  ShippingInfo({this.name});

  factory ShippingInfo.fromJson(Map<String, dynamic> json) {
    return ShippingInfo(name: json['name']);
  }

  Map<String, dynamic> toJson() {
    return {'name': name};
  }
}

class CartInfo {
  final List<ItemDetail>? itemDetails;

  CartInfo({this.itemDetails});

  factory CartInfo.fromJson(Map<String, dynamic> json) {
    return CartInfo(
      itemDetails: json['item_details'] != null
          ? (json['item_details'] as List<dynamic>)
                .map((e) => ItemDetail.fromJson(e))
                .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'item_details': itemDetails?.map((e) => e.toJson()).toList()};
  }
}

class ItemDetail {
  final String itemName;
  final String itemDescription;
  final String itemQuantity;
  final Amount? itemUnitPrice;
  final Amount? itemAmount;
  final Amount? totalItemAmount;

  ItemDetail({
    required this.itemName,
    required this.itemDescription,
    required this.itemQuantity,
    this.itemUnitPrice,
    this.itemAmount,
    this.totalItemAmount,
  });

  factory ItemDetail.fromJson(Map<String, dynamic> json) {
    return ItemDetail(
      itemName: json['item_name'],
      itemDescription: json['item_description'],
      itemQuantity: json['item_quantity'],
      itemUnitPrice: json['item_unit_price'] != null
          ? Amount.fromJson(json['item_unit_price'])
          : null,
      itemAmount: json['item_amount'] != null
          ? Amount.fromJson(json['item_amount'])
          : null,
      totalItemAmount: json['total_item_amount'] != null
          ? Amount.fromJson(json['total_item_amount'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'item_name': itemName,
      'item_description': itemDescription,
      'item_quantity': itemQuantity,
      'item_unit_price': itemUnitPrice?.toJson(),
      'item_amount': itemAmount?.toJson(),
      'total_item_amount': totalItemAmount?.toJson(),
    };
  }
}

class ApiLink {
  final String href;
  final String rel;
  final String method;

  ApiLink({required this.href, required this.rel, required this.method});

  factory ApiLink.fromJson(Map<String, dynamic> json) {
    return ApiLink(
      href: json['href'],
      rel: json['rel'],
      method: json['method'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'href': href, 'rel': rel, 'method': method};
  }
}
