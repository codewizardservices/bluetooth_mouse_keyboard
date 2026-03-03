// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'databases.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PurchaseDetailsSaveAdapter extends TypeAdapter<PurchaseDetailsSave> {
  @override
  final int typeId = 1;

  @override
  PurchaseDetailsSave read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PurchaseDetailsSave(
      purchaseID: fields[1] as dynamic,
      productID: fields[2] == null ? '' : fields[2] as String,
      verificationData: fields[3] == null ? '' : fields[3] as String,
      transactionDate: fields[4] as DateTime?,
      expireDate: fields[5] as DateTime?,
      status: fields[6] == null ? false : fields[6] as bool,
      originalTransactionId: fields[7] == null ? '' : fields[7] as String,
      webOrderLineItemId: fields[8] == null ? '' : fields[8] as String,
      price: fields[9] == null ? '' : fields[9] as String,
      currency: fields[10] == null ? '' : fields[10] as String,
      localizedPrice: fields[11] == null ? '' : fields[11] as String,
      isTrial: fields[12] == null ? false : fields[12] as bool,
      isInIntroOffer: fields[13] == null ? false : fields[13] as bool,
      inAppOwnershipType: fields[14] == null ? '' : fields[14] as String,
      subscriptionGroupIdentifier:
          fields[15] == null ? '' : fields[15] as String,
      autoRenewProductId: fields[16] == null ? '' : fields[16] as String,
      autoRenewStatus: fields[17] == null ? false : fields[17] as bool,
      nextRenewalDate: fields[18] as DateTime?,
      cancellationDate: fields[19] as DateTime?,
      receiptEnvironment: fields[20] == null ? '' : fields[20] as String,
      httpStatusCode: fields[21] == null ? 0 : fields[21] as int,
      receiptMessage: fields[22] == null ? '' : fields[22] as String,
      platform: fields[23] == null ? '' : fields[23] as String,
      subscriptionStatus: fields[24] as SubscriptionStatus,
    );
  }

  @override
  void write(BinaryWriter writer, PurchaseDetailsSave obj) {
    writer
      ..writeByte(24)
      ..writeByte(1)
      ..write(obj.purchaseID)
      ..writeByte(2)
      ..write(obj.productID)
      ..writeByte(3)
      ..write(obj.verificationData)
      ..writeByte(4)
      ..write(obj.transactionDate)
      ..writeByte(5)
      ..write(obj.expireDate)
      ..writeByte(6)
      ..write(obj.status)
      ..writeByte(7)
      ..write(obj.originalTransactionId)
      ..writeByte(8)
      ..write(obj.webOrderLineItemId)
      ..writeByte(9)
      ..write(obj.price)
      ..writeByte(10)
      ..write(obj.currency)
      ..writeByte(11)
      ..write(obj.localizedPrice)
      ..writeByte(12)
      ..write(obj.isTrial)
      ..writeByte(13)
      ..write(obj.isInIntroOffer)
      ..writeByte(14)
      ..write(obj.inAppOwnershipType)
      ..writeByte(15)
      ..write(obj.subscriptionGroupIdentifier)
      ..writeByte(16)
      ..write(obj.autoRenewProductId)
      ..writeByte(17)
      ..write(obj.autoRenewStatus)
      ..writeByte(18)
      ..write(obj.nextRenewalDate)
      ..writeByte(19)
      ..write(obj.cancellationDate)
      ..writeByte(20)
      ..write(obj.receiptEnvironment)
      ..writeByte(21)
      ..write(obj.httpStatusCode)
      ..writeByte(22)
      ..write(obj.receiptMessage)
      ..writeByte(23)
      ..write(obj.platform)
      ..writeByte(24)
      ..write(obj.subscriptionStatus);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PurchaseDetailsSaveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SubscriptionStatusAdapter extends TypeAdapter<SubscriptionStatus> {
  @override
  final int typeId = 0;

  @override
  SubscriptionStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return SubscriptionStatus.active;
      case 1:
        return SubscriptionStatus.expired;
      case 2:
        return SubscriptionStatus.pending;
      case 3:
        return SubscriptionStatus.cancelled;
      case 4:
        return SubscriptionStatus.paused;
      case 5:
        return SubscriptionStatus.noSubscription;
      case 6:
        return SubscriptionStatus.interstitialFree;
      case 7:
        return SubscriptionStatus.adsFree;
      default:
        return SubscriptionStatus.active;
    }
  }

  @override
  void write(BinaryWriter writer, SubscriptionStatus obj) {
    switch (obj) {
      case SubscriptionStatus.active:
        writer.writeByte(0);
        break;
      case SubscriptionStatus.expired:
        writer.writeByte(1);
        break;
      case SubscriptionStatus.pending:
        writer.writeByte(2);
        break;
      case SubscriptionStatus.cancelled:
        writer.writeByte(3);
        break;
      case SubscriptionStatus.paused:
        writer.writeByte(4);
        break;
      case SubscriptionStatus.noSubscription:
        writer.writeByte(5);
        break;
      case SubscriptionStatus.interstitialFree:
        writer.writeByte(6);
        break;
      case SubscriptionStatus.adsFree:
        writer.writeByte(7);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubscriptionStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
