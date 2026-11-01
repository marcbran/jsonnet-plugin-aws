{
  call(ctx, service, operation, input={}): std.native('invoke:aws')('call', [ctx, service, operation, input]),
}
