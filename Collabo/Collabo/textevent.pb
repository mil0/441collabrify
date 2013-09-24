enum EventType {
  INSERT = 0;
  REMOVE = 1;
  CURSORMOVE = 2;
  UNDO = 3;
  REDO = 4;
}

message Event {
  optional EventType eventType = 1;
  optional int32 initialCursorLocation = 2;
  optional int32 newCursorLocation = 3;
  optional int32 changeLength = 4;
  optional string textAdded = 5;  
  optional int64 userID = 6;
}
