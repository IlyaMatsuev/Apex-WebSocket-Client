trigger WSUpdate on WSUpdate__e(after insert) {
    new WSUpdateEventHandler((List<WSUpdate__e>) Trigger.new).handle();
}
