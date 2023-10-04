import '../models/reservation.dart';
import 'base_provider.dart';

class ReservationProvider extends BaseProvider<Reservation> {
  ReservationProvider() : super('Reservation/GetPaged');

  @override
  Reservation fromJson(data) {
    return Reservation.fromJson(data);
  }
}
