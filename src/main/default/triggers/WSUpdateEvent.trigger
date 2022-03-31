trigger WSUpdateEvent on WSUpdateEvent__e(after insert) {
    new WSUpdateEventHandler(Trigger.new).handle();
}
