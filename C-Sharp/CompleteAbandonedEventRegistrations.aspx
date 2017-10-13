<%@ Page Language="C#" Inherits="System.Web.UI.Page" Title="Complete Abandoned Registrations" %>

<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="Asi.Soa.ClientServices" %>
<%@ Import Namespace="Asi.Soa.Commerce.DataContracts" %>
<%@ Import Namespace="Asi.Soa.Core.DataContracts" %>
<%@ Import Namespace="Asi.Soa.Events.DataContracts" %>
<%@ Import Namespace="Asi.Soa.Membership.DataContracts" %>
<%@ Import Namespace="Newtonsoft.Json" %>

<script language="C#" runat="server">

    internal EntityManager entityManager;

    const bool runForReal = true;

    const string eventId = "SCC17ATT";
    const string eventFunctionId = "SCC17ATT/ATT";

    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);

        entityManager = new EntityManager("MANAGER");

        var ids = new string[] { "264702","228991", };

        foreach (var partyId in ids) {
            try {
                CartManager cartManager = new CartManager(entityManager, partyId);

                // Delete the cart
                Response.Write(string.Format("Deleting cart for user with ID {0}<br />", partyId));
                if (runForReal) doDeleteCart(cartManager);

                // Register the user
                Response.Write(string.Format("Registering user with ID {0} for {1}<br />", partyId, eventFunctionId));
                if (runForReal) doRegistration(partyId, cartManager);
            } catch (Exception ex){
                Response.Write("Failed to delete the cart and register the user for event. iMIS ID " + partyId + " event code: " + eventFunctionId);
            }
        }
    }

    internal void doDeleteCart(CartManager cartManager)
    {
        cartManager.DeleteCart();
    }

    internal void doRegistration(string partyId, CartManager cartManager)
    {
        var eventManager = new EventManager(entityManager, eventId);
        var eventRegData = eventManager.GetRegistrationData(partyId, partyId);
        var registrationstatus = eventRegData.Status;
        eventManager.RegisterFunction(partyId, partyId, eventFunctionId);

        var comboOrder = cartManager.Cart.ComboOrder;

        var customer = new CustomerPartyData { PartyId = partyId };
        var Payor = new CustomerPartyData { PartyId = partyId };

        comboOrder.Order.BillToCustomerParty = Payor;
        comboOrder.Order.SoldToCustomerParty = customer;

        var delivery = new DeliveryData { DeliveryMethod = new DeliveryMethodData { DeliveryMethodId = "None" } };
        comboOrder.Order.Delivery = new DeliveryDataCollection { delivery };
        comboOrder.Order.Delivery[0].Address = new FullAddressData
        {
            Address = new AddressData { AddressLines = new AddressLineDataCollection { "1 Main Street" } }
        };

        var paymentData = new RemittanceData
        {
            //PaymentMethod = new PaymentMethodData
            //{
            //    CSCRequired = false,
            //    IssueDateRequired = false,
            //    IssueNumberRequired = false,
            //    Name = "VISA",
            //    PaymentMethodId = "W_VISA",
            //    PaymentType = "CreditCard"
            //},
            //CreditCardInformation = new CreditCardInformationData
            //{
            //    //Address = new AddressData(), - fill object as appropriate
            //    CardNumber = "4111111111111111",
            //    CardType = "VISA",
            //    Expiration = new YearMonthDateData(2020, 12),
            //    HoldersName = "Card holders name"
            //},

            //PaymentMethod = new PaymentMethodData {  PaymentMethodId = "CASH" },

            PaymentMethod = new PaymentMethodData { PaymentMethodId = "CASH", PaymentType = "CreditCard" },

            CreditCardInformation = new CreditCardInformationData
            {

            },

            ReferenceNumber = "ABC",

            PaymentDate = DateTime.Now,

            Amount =
               comboOrder.Order.OrderTotal ??
               new MonetaryAmountData(0, cartManager.Cart.ComboOrder.Order.Currency)
        };
        comboOrder.Payments = new RemittanceDataCollection { paymentData };

        var results = cartManager.ValidateCart();

        if (!results.IsValid)
        {
            var error = results.ValidationResults.Summary;
        }
        else
        {
            var comboOrderResults = entityManager.Add(comboOrder); // Check-out
            //cartManager.SubmitCart();
        }
    }

    internal List<string> getPartyIdsWithCarts()
    {
        List<string> partyIdsWithCarts = new List<string>();

        using (SqlConnection sqlConn = new SqlConnection(ConfigurationManager.ConnectionStrings["DataSource.iMIS.Connection"].ConnectionString))
        {
            sqlConn.Open();

            using (SqlCommand sqlCom = new SqlCommand())
            {
                sqlCom.Connection = sqlConn;
                sqlCom.CommandText = "SELECT DISTINCT Cart.UserId FROM Cart WHERE Cart.UserId <> 'anonymous'";

                SqlDataReader dataReader = sqlCom.ExecuteReader();

                while (dataReader.Read())
                {
                    partyIdsWithCarts.Add(dataReader["UserId"].ToString());
                }
            }

            sqlConn.Close();
        }

        return partyIdsWithCarts;
    }

    private readonly static Newtonsoft.Json.JsonSerializerSettings jsonSerializerSettings = new Newtonsoft.Json.JsonSerializerSettings()
    {
        TypeNameHandling = TypeNameHandling.All,
        Binder = new DataContractSerializationBinder(),
        NullValueHandling = Newtonsoft.Json.NullValueHandling.Include
    };

    private class DataContractSerializationBinder : Newtonsoft.Json.Serialization.DefaultSerializationBinder
    {
        public DataContractSerializationBinder()
        {
        }

        public override Type BindToType(string assemblyName, string typeName)
        {
            if ((assemblyName == null ? false : typeName != null))
            {
                if (NamespaceChanges.ContainsKey(assemblyName))
                {
                    assemblyName = NamespaceChanges[assemblyName];
                }
                if ((!assemblyName.Equals("mscorlib", StringComparison.Ordinal) ? false : typeName.StartsWith("System.Nullable", StringComparison.Ordinal)))
                {
                    foreach (KeyValuePair<string, string> namespaceChange in NamespaceChanges)
                    {
                        if (typeName.Contains(namespaceChange.Key))
                        {
                            typeName = typeName.Replace(namespaceChange.Key, namespaceChange.Value);
                            break;
                        }
                    }
                }
            }
            return base.BindToType(assemblyName, typeName);
        }

        public static Dictionary<string, string> NamespaceChanges = new Dictionary<string, string>()
            {
                { "Asi.Soa.Core.Contracts", "Asi.Contracts" },
                { "Asi.Soa.Commerce.Contracts", "Asi.Contracts" },
                { "Asi.Soa.Certification.Contracts", "Asi.Contracts" },
                { "Asi.Soa.Communications.Contracts", "Asi.Contracts" },
                { "Asi.Soa.Events.Contracts", "Asi.Contracts" },
                { "Asi.Soa.Fundraising.Contracts", "Asi.Contracts" },
                { "Asi.Soa.Membership.Contracts", "Asi.Contracts" },
                { "Asi.Soa.Nrds.Contracts", "Asi.Contracts" }
            };
    }

</script>

