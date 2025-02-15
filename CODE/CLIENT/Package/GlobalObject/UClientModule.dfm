object ClientModule: TClientModule
  Height = 475
  Width = 788
  PixelsPerInch = 96
  object conn: TSQLConnection
    ConnectionName = 'DataSnapCONNECTION'
    DriverName = 'DataSnap'
    LoginPrompt = False
    Params.Strings = (
      'DriverUnit=Data.DBXDataSnap'
      'CommunicationProtocol=tcp/ip'
      'DatasnapContext=datasnap/'
      
        'DriverAssemblyLoader=Borland.Data.TDBXClientDriverLoader,Borland' +
        '.Data.DbxClientDriver,Version=24.0.0.0,Culture=neutral,PublicKey' +
        'Token=91d62ebb5b0d1b1b'
      'DriverName=DataSnap'
      'HostName=localhost'
      'Port=212'
      
        'ConnectionString=DriverUnit=Data.DBXDataSnap,CommunicationProtoc' +
        'ol=tcp/ip,DatasnapContext=datasnap/,DriverAssemblyLoader=Borland' +
        '.Data.TDBXClientDriverLoader,Borland.Data.DbxClientDriver,Versio' +
        'n=24.0.0.0,Culture=neutral,PublicKeyToken=91d62ebb5b0d1b1b,Drive' +
        'rName=DataSnap,HostName=localhost,port=212'
      'Filters={}'
      'BufferKBSize=512'
      'DSProxyPort=8080')
    Left = 72
    Top = 24
    UniqueId = '{E58723E9-A7EC-436D-B582-C639EF7C4ADD}'
  end
  object DSProvider_OpenSQL: TDSProviderConnection
    ServerClassName = 'TModuleUnit'
    SQLConnection = conn
    Left = 69
    Top = 96
  end
  object DSProvider_OpenPRoc: TDSProviderConnection
    ServerClassName = 'TModuleUnit'
    SQLConnection = conn
    Left = 69
    Top = 152
  end
  object ConnectTimer: TTimer
    Enabled = False
    Interval = 20000
    OnTimer = ConnectTimerTimer
    Left = 128
    Top = 24
  end
end
