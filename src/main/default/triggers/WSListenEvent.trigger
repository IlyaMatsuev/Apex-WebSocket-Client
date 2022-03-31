trigger WSListenEvent on WSListenEvent__e(after insert) {
    new WSListenEventHandler(Trigger.new).handle();
}
