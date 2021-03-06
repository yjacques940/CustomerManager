﻿using Microsoft.AspNetCore.Mvc;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using WebApi.Models;
using WebApi.Services;

namespace WebApi.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class PhoneTypesController : BaseReaderController<PhoneTypeService, PhoneType>
    {
        public PhoneTypesController(PhoneTypeService service) : base(service)
        {
        }
    }
}
