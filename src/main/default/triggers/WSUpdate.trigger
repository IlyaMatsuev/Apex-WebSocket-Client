trigger WSUpdate on WSUpdate__e(before insert) {
    List<WSUpdate__e> updates = (WSUpdate__e) Trigger.new;
}
