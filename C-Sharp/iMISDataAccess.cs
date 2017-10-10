using System;
using System.Collections.Generic;
using System.Linq;
using log4net;
using Asi.Soa.ClientServices;
using Asi.Soa.Core.DataContracts;
using BSI.MyProject.Models;

namespace BSI.MyProject.DataAccess
{
    public class iMISDataAccess
    {
        protected readonly EntityManager EntityManager = new EntityManager("MANAGER");
        protected readonly ILog _logger = LogManager.GetLogger(MethodBase.GetCurrentMethod().DeclaringType);

        public void SaveModel(MyModel myModel)
        {
            var modelObject = new JavaScriptSerializer().Serialize(myModel);

            try
            {
                var record = EntityManager.FindSingle<T>(CriteriaData.Equal("ID", myModel.PartyId));
                
                if (record == null)
                {
                    // Insert
                    results = EntityManager.Add(data);
                }
                else
                {
                    // Update
                    results = EntityManager.Update(data);
                }

                if (!results.IsValid)
                    throw new ApplicationException(results.ValidationResults.Summary);
            }
            catch (Exception ex)
            {
                _logger.Error($"ERROR creating/updating object. Object: {modelObject} - error: {ex.Message}, {ex.StackTrace}");
                throw;
            }
        }
    }
}
