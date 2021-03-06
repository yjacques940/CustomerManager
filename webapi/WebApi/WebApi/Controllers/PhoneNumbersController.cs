﻿using Microsoft.AspNetCore.Mvc;
using System.Collections.Generic;
using WebApi.DTO;
using WebApi.Models;
using WebApi.Services;

namespace WebApi.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class PhoneNumbersController : BaseController<PhoneNumberService, PhoneNumber>
    {
        public PhoneNumbersController(PhoneNumberService service) : base(service)
        {
        }

        [HttpGet, Route("ForCustomer/{id}")]
        public List<PhoneNumberAndTypesInformation> GetPhoneNumberForCustomer(int id)
        {
            return Service.GetPhoneNumbersForCustomer(id);
        }
    }
}
